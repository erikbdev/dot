-- iOS development workspace and actions for Rex.

local terminal_creator = "com.superlogical.terminal"
local terminal_flavor = "com.superlogical.terminal.shell"
local home = os.getenv("HOME") or ""
local browse_id = "__browse_for_ios_project__"

local extra_path = {}
if home ~= "" then
  table.insert(extra_path, home .. "/.local/bin")
end
table.insert(extra_path, "/opt/homebrew/bin")
table.insert(extra_path, "/usr/local/bin")

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalize_path(path)
  path = trim(path)
  if path == "~" then
    path = home
  elseif path:sub(1, 2) == "~/" then
    path = home .. path:sub(2)
  end
  if #path > 1 then
    path = path:gsub("/+$", "")
  end
  return path
end

local function basename(path)
  return normalize_path(path):match("([^/]+)$") or path
end

local function fail(message)
  error("iOS: " .. tostring(message), 0)
end

local function output_of(result)
  local output = trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
  if output == "" then
    return "exit code " .. tostring(result.code)
  end
  return output
end

local function executable(name)
  local directories = {}
  local seen = {}

  local function add(directory)
    if directory and directory ~= "" and not seen[directory] then
      seen[directory] = true
      table.insert(directories, directory)
    end
  end

  for _, directory in ipairs(extra_path) do
    add(directory)
  end
  for directory in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    add(directory)
  end
  add("/usr/bin")
  add("/bin")

  for _, directory in ipairs(directories) do
    local path = directory .. "/" .. name
    local result = rex.exec({ "/bin/test", "-x", path })
    if result and result.ok then
      return path
    end
  end

  return nil
end

local function path_prepend()
  local paths = {}
  local seen = {}
  for _, directory in ipairs(extra_path) do
    if not seen[directory] then
      seen[directory] = true
      table.insert(paths, directory)
    end
  end
  return paths
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function fallback_shell(message)
  local script = "printf '%s\\n' " .. shell_quote(message) .. "; exec /bin/zsh -l"
  return { "/bin/zsh", "-l", "-c", script }
end

local function terminal_block(cwd, command)
  local options = {
    cwd = cwd,
    path_prepend = path_prepend(),
    exit = { on_completion = false },
  }

  if command then
    options.command = command
    options.shell = "none"
  end

  return rex.layout.block({
    flavor = terminal_flavor,
    options = options,
  })
end

local function run_find(root, depth)
  local argv = {
    "/usr/bin/find",
    root,
    "-maxdepth", tostring(depth),
    "(", "-name", ".git", "-o", "-name", "node_modules",
    "-o", "-name", "DerivedData", "-o", "-name", ".build",
    "-o", "-name", "Pods", ")",
    "-prune", "-o",
    "(", "-type", "d", "(", "-name", "*.xcodeproj",
    "-o", "-name", "*.xcworkspace", ")",
    "-o", "-type", "f", "-name", "Package.swift", ")",
    "-print",
  }
  local result, err = rex.exec(argv, { timeout = 15 })
  if not result then
    return nil, err
  end

  local paths = {}
  for path in (result.stdout or ""):gmatch("[^\r\n]+") do
    table.insert(paths, normalize_path(path))
  end

  if not result.ok and #paths == 0 then
    return nil, output_of(result)
  end
  return paths
end

local function project_roots()
  local configured = os.getenv("IOS_PROJECT_ROOTS")
  local roots = {}

  if configured and configured ~= "" then
    for root in configured:gmatch("[^:]+") do
      if root == "~" then
        root = home
      elseif root:sub(1, 2) == "~/" then
        root = home .. root:sub(2)
      end
      table.insert(roots, normalize_path(root))
    end
    return roots
  end

  if home == "" then
    return roots
  end

  return {
    home .. "/Developer",
    home .. "/Projects",
    home .. "/Code",
    home .. "/src",
    home .. "/Workspaces",
    home .. "/Documents/Projects",
    home .. "/Library/Developer/Xcode/Projects",
  }
end

local function is_directory(path)
  local result, err = rex.exec({ "/bin/test", "-d", path })
  if not result then
    return false, err
  end
  return result.ok
end

local function inspect_project(path)
  path = normalize_path(path)
  if path == "" then
    return false, "The selected project path is empty."
  end

  local is_dir, dir_error = is_directory(path)
  if not is_dir then
    return false, "Directory not found: " .. path .. (dir_error and (": " .. dir_error) or "")
  end

  local markers, find_error = run_find(path, 5)
  if not markers then
    return false, "Could not inspect " .. path .. ": " .. tostring(find_error)
  end
  if #markers == 0 then
    return false, path .. " contains no .xcodeproj, .xcworkspace, or Package.swift."
  end

  return true, path
end

local function validate_project(path)
  local valid, result = inspect_project(path)
  if not valid then
    fail(result)
  end
  return result
end

local function project_from_marker(marker)
  return marker:match("^(.*)/[^/]+$") or marker
end

local function discover_projects()
  local roots = {}
  for _, root in ipairs(project_roots()) do
    if is_directory(root) then
      table.insert(roots, root)
    end
  end

  local projects = {}
  local scan_error
  if #roots > 0 then
    local argv = { "/usr/bin/find" }
    for _, root in ipairs(roots) do
      table.insert(argv, root)
    end
    local expression = {
      "-maxdepth", "5",
      "(", "-name", ".git", "-o", "-name", "node_modules",
      "-o", "-name", "DerivedData", "-o", "-name", ".build",
      "-o", "-name", "Pods", ")",
      "-prune", "-o",
      "(", "-type", "d", "(", "-name", "*.xcodeproj",
      "-o", "-name", "*.xcworkspace", ")",
      "-o", "-type", "f", "-name", "Package.swift", ")",
      "-print",
    }
    for _, part in ipairs(expression) do
      table.insert(argv, part)
    end

    local result, err = rex.exec(argv, { timeout = 15 })
    if not result then
      scan_error = tostring(err)
    else
      if not result.ok then
        scan_error = output_of(result)
      end
      for marker in (result.stdout or ""):gmatch("[^\r\n]+") do
        marker = normalize_path(marker)
        local project = project_from_marker(marker)
        local kind = marker:match("%.xcworkspace$") and "Xcode workspace"
          or marker:match("%.xcodeproj$") and "Xcode project"
          or "Swift Package"
        local rank = kind == "Xcode workspace" and 3
          or kind == "Xcode project" and 2
          or 1
        local existing = projects[project]
        if not existing or rank > existing.rank then
          projects[project] = {
            id = project,
            title = basename(project),
            subtitle = project,
            detail = kind,
            icon = "folder",
            rank = rank,
          }
        end
      end
    end
  end

  local items = {}
  for _, item in pairs(projects) do
    item.rank = nil
    table.insert(items, item)
  end
  table.sort(items, function(a, b)
    local a_name = a.title:lower()
    local b_name = b.title:lower()
    if a_name == b_name then
      return a.subtitle:lower() < b.subtitle:lower()
    end
    return a_name < b_name
  end)

  return items, scan_error
end

local function choose_item(title, placeholder, items)
  local id, why, detail = rex.ui.pick({
    title = title,
    placeholder = placeholder,
    items = items,
  })
  if id ~= nil then
    return id
  end
  if why == nil or why == "cancelled" then
    return nil
  end
  fail(title .. " could not be shown (" .. tostring(why)
    .. (detail and (": " .. detail) or "") .. ").")
end

local function choose_text(title, placeholder, value)
  local text, why, detail = rex.ui.input({
    title = title,
    placeholder = placeholder,
    value = value,
  })
  if text ~= nil then
    return text
  end
  if why == nil or why == "cancelled" then
    return nil
  end
  fail(title .. " could not be shown (" .. tostring(why)
    .. (detail and (": " .. detail) or "") .. ").")
end

local function browse_for_project()
  local script = 'POSIX path of (choose folder with prompt "Choose an Xcode or Swift project folder")'
  local result, err = rex.exec({ "/usr/bin/osascript", "-e", script }, { timeout = 25 })
  if result and result.ok then
    return normalize_path(result.stdout)
  end

  local reason = result and output_of(result) or tostring(err)
  if result then
    local lower = reason:lower()
    if lower:find("user canceled", 1, true) or lower:find("-128", 1, true) then
      return nil
    end
  end

  reason = trim(reason):gsub("\n.*", "")
  if #reason > 180 then
    reason = reason:sub(1, 177) .. "..."
  end
  rex.log("warn", "Native folder picker unavailable: " .. reason)
  local path = choose_text(
    "macOS folder picker unavailable (" .. reason .. ")",
    "Paste a project directory path…",
    home
  )
  if not path or trim(path) == "" then
    return nil
  end
  return normalize_path(path)
end

local function choose_project()
  local projects, scan_error = discover_projects()
  local items = projects
  if scan_error then
    table.insert(items, {
      id = "__project_scan_error__",
      title = "Project search had an error",
      subtitle = scan_error:sub(1, 160),
      icon = "gear",
    })
  end
  table.insert(items, {
    id = browse_id,
    title = "Browse for a project folder…",
    subtitle = "Choose a folder in macOS",
    icon = "plus",
  })

  local selected = choose_item(
    "Select iOS or Swift Project",
    "Search project names and paths…",
    items
  )
  if not selected then
    return nil
  end
  if selected == "__project_scan_error__" then
    fail("Project search failed: " .. tostring(scan_error))
  end
  if selected == browse_id then
    selected = browse_for_project()
    if not selected then
      return nil
    end
  end

  return validate_project(selected)
end

local function path_from_url(value)
  if not value or value == "" then
    return nil
  end
  local path = value
  if path:sub(1, 7) == "file://" then
    path = path:gsub("^file://[^/]*", "")
    path = path:gsub("%%(%x%x)", function(hex)
      return string.char(tonumber(hex, 16))
    end)
  end
  return normalize_path(path)
end

local function current_project(ctx)
  local path
  if ctx and ctx.block_id then
    local result = rex.block.call(terminal_creator, "pwd", {
      block_id = ctx.block_id,
    })
    if result then
      path = path_from_url(result.pwd)
    end
  end
  if not path then
    path = path_from_url(os.getenv("PWD"))
  end

  if path then
    local valid = inspect_project(path)
    if valid then
      return path
    end
  end
  return choose_project()
end

local function workspace_label(project)
  local label = "iOS Development: " .. project
  if #label <= 128 then
    return label
  end
  return ("iOS Development: " .. basename(project) .. " · " .. project:sub(-80)):sub(1, 128)
end

local function create_workspace(project)
  local label = workspace_label(project)
  local view, view_error = rex.session.view({})
  if not view then
    fail("Could not inspect the current session: " .. tostring(view_error))
  end

  for _, window in ipairs(view.windows or {}) do
    if window.label == label then
      local _, focus_error = rex.session.focus_window({
        window_id = window.window_id,
      })
      if focus_error then
        fail("Could not focus the existing iOS workspace: " .. tostring(focus_error))
      end
      return { window_id = window.window_id, project_path = project, reused = true }
    end
  end

  local nvim = executable("nvim")
  local codex = executable("codex")
  local phone = executable("terminal-phone")

  local editor_command = nvim
    and { nvim }
    or fallback_shell("nvim was not found. Install it or add it to PATH, then run nvim here.")
  local agent_command = codex
    and { codex }
    or fallback_shell("codex was not found. Install it or add it to PATH, then run codex here.")

  local simulator_command
  if not phone then
    simulator_command = fallback_shell(
      "terminal-phone was not found. Install it or add it to PATH. No Simulator was started."
    )
  else
    local status, status_error = rex.exec({ phone, "status", "default" }, { timeout = 5 })
    if status and status.ok then
      simulator_command = { phone, "view", "work", "--protocol", "kitty" }
    else
      local reason = status and output_of(status) or tostring(status_error)
      simulator_command = fallback_shell(
        "terminal-phone could not open the existing target 'work': "
          .. reason
          .. "\nNo Simulator was created. Check terminal-phone devices and start or register a target manually."
      )
    end
  end

  local top = rex.layout.horizontal(
    0.5,
    terminal_block(project, editor_command),
    terminal_block(project, simulator_command)
  )
  local bottom = rex.layout.horizontal(
    0.5,
    terminal_block(project, agent_command),
    terminal_block(project, nil)
  )
  local layout = rex.layout.vertical(0.5, top, bottom)

  local window, err = rex.session.new_window({
    window_label = label,
    layout = layout,
  })
  if not window then
    fail("Could not create the iOS workspace: " .. tostring(err or "Rex returned no window"))
  end
  if err then
    fail("Could not create the iOS workspace: " .. tostring(err))
  end

  return {
    window_id = window.window_id,
    project_path = project,
    simulator = simulator_command[2] == "view" and "work" or "unavailable",
  }
end

rex.action({
  name = "ios_workspace",
  title = "iOS: Open Workspace",
  category = "Development",
  description = "Choose an Xcode or Swift project and open Neovim, Codex, Simulator, and a shell.",
  args = { project_path = "string?" },
  run = function(ctx, args)
    local project
    if args.project_path then
      project = validate_project(args.project_path)
    else
      project = choose_project()
    end
    if not project then
      return
    end
    return create_workspace(project)
  end,
})

local function project_markers(project)
  local markers, err = run_find(project, 5)
  if not markers then
    fail("Could not inspect " .. project .. ": " .. tostring(err))
  end
  return markers
end

local function xcode_containers(project)
  local containers = {}
  for _, marker in ipairs(project_markers(project)) do
    local kind = marker:match("%.xcworkspace$") and "Xcode workspace"
      or marker:match("%.xcodeproj$") and "Xcode project"
    if kind then
      table.insert(containers, {
        id = marker,
        title = basename(marker),
        subtitle = marker,
        detail = kind,
        icon = "package",
      })
    end
  end
  table.sort(containers, function(a, b)
    if a.detail ~= b.detail then
      return a.detail == "Xcode workspace"
    end
    return a.title:lower() < b.title:lower()
  end)
  return containers
end

local function select_container(project)
  local containers = xcode_containers(project)
  if #containers == 0 then
    return nil
  end
  if #containers == 1 then
    return containers[1]
  end
  local items = {}
  for _, container in ipairs(containers) do
    table.insert(items, container)
  end
  local path = choose_item("Select Xcode Project or Workspace", "Filter Xcode projects…", items)
  if not path then
    return nil
  end
  for _, container in ipairs(containers) do
    if container.id == path then
      return container
    end
  end
  return nil
end

local function list_schemes(project, container)
  local xcodebuild = executable("xcodebuild")
  if not xcodebuild then
    fail("xcodebuild was not found. Install Xcode and make it available in PATH.")
  end

  local kind = container.detail == "Xcode workspace" and "-workspace" or "-project"
  local result, err = rex.exec({
    xcodebuild, "-list", "-json", kind, container.id,
  }, { cwd = project, timeout = 15 })
  if not result then
    fail("Could not run xcodebuild -list: " .. tostring(err))
  end
  if not result.ok then
    fail("Could not list Xcode schemes: " .. output_of(result))
  end

  local data, decode_error = rex.json.decode(result.stdout)
  if not data then
    fail("xcodebuild returned invalid JSON: " .. tostring(decode_error))
  end
  local details = data.workspace or data.project or data
  local schemes = {}
  for _, scheme in ipairs(details.schemes or {}) do
    table.insert(schemes, scheme)
  end
  table.sort(schemes, function(a, b)
    return a:lower() < b:lower()
  end)
  if #schemes == 0 then
    fail("No schemes were found in " .. container.id .. ".")
  end
  return schemes
end

local function select_scheme(project, container)
  local schemes = list_schemes(project, container)
  if #schemes == 1 then
    return schemes[1]
  end
  local items = {}
  for _, scheme in ipairs(schemes) do
    table.insert(items, { id = scheme, title = scheme, icon = "code" })
  end
  return choose_item("Select Xcode Scheme", "Filter schemes…", items)
end

local function available_simulators()
  local xcrun = executable("xcrun")
  if not xcrun then
    fail("xcrun was not found. Install Xcode command line tools.")
  end
  local result, err = rex.exec({
    xcrun, "simctl", "list", "devices", "available", "--json",
  }, { timeout = 15 })
  if not result then
    fail("Could not list iOS Simulators: " .. tostring(err))
  end
  if not result.ok then
    fail("Could not list iOS Simulators: " .. output_of(result))
  end

  local data, decode_error = rex.json.decode(result.stdout)
  if not data then
    fail("simctl returned invalid JSON: " .. tostring(decode_error))
  end

  local items = {}
  for runtime, devices in pairs(data.devices or {}) do
    if runtime:find("iOS", 1, true) then
      for _, device in ipairs(devices) do
        if device.isAvailable ~= false and device.udid then
          table.insert(items, {
            id = device.udid,
            title = device.name,
            subtitle = device.state .. " · " .. runtime,
            detail = device.udid,
            icon = "terminal",
          })
        end
      end
    end
  end
  table.sort(items, function(a, b)
    return a.title:lower() < b.title:lower()
  end)
  if #items == 0 then
    fail("No available iOS Simulator devices were found.")
  end
  return items
end

local function require_phone()
  local phone = executable("terminal-phone")
  if not phone then
    fail("terminal-phone was not found. Install it or add it to PATH.")
  end
  local result, err = rex.exec({ phone, "status", "default" }, { timeout = 5 })
  if not result then
    fail("Could not check terminal-phone target 'default': " .. tostring(err))
  end
  if not result.ok then
    fail("terminal-phone target 'work' is unavailable: " .. output_of(result))
  end
  return phone
end

local function open_window(label, project, command)
  local window, err = rex.session.new_window({
    window_label = label,
    layout = terminal_block(project or home, command),
  })
  if not window then
    fail("Could not open " .. label .. ": " .. tostring(err or "Rex returned no window"))
  end
  if err then
    fail("Could not open " .. label .. ": " .. tostring(err))
  end
  return window
end

local function launch_build(project, scheme, container, test_kind, test_target, simulator)
  local xcodebuild = executable("xcodebuild")
  if not xcodebuild then
    fail("xcodebuild was not found. Install Xcode and make it available in PATH.")
  end

  local command = { xcodebuild }
  local kind = container.detail == "Xcode workspace" and "-workspace" or "-project"
  table.insert(command, kind)
  table.insert(command, container.id)
  table.insert(command, "-scheme")
  table.insert(command, scheme)

  local label
  if test_kind then
    table.insert(command, "test")
    table.insert(command, "-destination")
    table.insert(command, "platform=iOS Simulator,id=" .. simulator.id)
    if test_target and test_target ~= "" then
      table.insert(command, "-only-testing:" .. test_target)
    end
    label = test_kind == "ui" and "iOS UI Tests: " .. scheme or "iOS Unit Tests: " .. scheme
  else
    table.insert(command, "-sdk")
    table.insert(command, "iphonesimulator")
    table.insert(command, "build")
    label = "iOS Build: " .. scheme
  end

  local window = open_window(label, project, command)
  return { window_id = window.window_id, scheme = scheme, project_path = project }
end

local function xcode_action(ctx, kind)
  local project = current_project(ctx)
  if not project then
    return
  end

  local container = select_container(project)
  if not container then
    if kind == "build" then
      local swift = executable("swift")
      if not swift then
        fail("This Swift package has no Xcode project or workspace, and swift was not found.")
      end
      local window = open_window("Swift Build", project, { swift, "build" })
      return { window_id = window.window_id, project_path = project }
    elseif kind == "unit" then
      local swift = executable("swift")
      if not swift then
        fail("This Swift package has no Xcode project or workspace, and swift was not found.")
      end
      local window = open_window("Swift Tests", project, { swift, "test" })
      return { window_id = window.window_id, project_path = project }
    end
    fail("UI tests require an .xcodeproj or .xcworkspace.")
  end

  local scheme = select_scheme(project, container)
  if not scheme then
    return
  end
  if kind == "build" then
    return launch_build(project, scheme, container)
  end

  local target
  if kind == "ui" then
    target = choose_text("UI Test Target", "For example: MyAppUITests", "")
    if target == nil then
      return
    end
    target = trim(target)
    if target == "" then
      fail("Enter a UI test target, such as MyAppUITests.")
    end
  end

  local devices = available_simulators()
  local device_id = choose_item(
    "Select Simulator for Tests",
    "Search available iOS Simulators…",
    devices
  )
  if not device_id then
    return
  end
  local device
  for _, item in ipairs(devices) do
    if item.id == device_id then
      device = item
      break
    end
  end
  if not device then
    fail("The selected Simulator is no longer available.")
  end

  return launch_build(project, scheme, container, kind, target, device)
end

rex.action({
  name = "ios_actions",
  title = "iOS: Actions",
  category = "Development",
  description = "Build, test, inspect Simulators, and open iOS development tools.",
  run = function(ctx)
    local selected = choose_item("iOS Actions", "Search actions…", {
      { id = "build", title = "Build current Xcode scheme", icon = "gear" },
      { id = "unit", title = "Run unit tests", icon = "gear" },
      { id = "ui", title = "Run UI tests", icon = "gear" },
      { id = "simulators", title = "List and select iOS Simulators", icon = "terminal" },
      { id = "phone", title = "Open or reconnect to terminal-phone", icon = "terminal" },
      { id = "logs", title = "View Simulator logs", icon = "terminal" },
      { id = "screenshot", title = "Capture a Simulator screenshot", icon = "document" },
      { id = "codex", title = "Open an additional Codex pane", icon = "code" },
    })
    if not selected then
      return
    end

    if selected == "build" or selected == "unit" or selected == "ui" then
      return xcode_action(ctx, selected)
    elseif selected == "simulators" then
      local devices = available_simulators()
      local device_id = choose_item("Available iOS Simulators", "Search devices…", devices)
      if not device_id then
        return
      end
      for _, device in ipairs(devices) do
        if device.id == device_id then
          rex.log("info", "Selected Simulator: " .. device.title .. " (" .. device.id .. ")")
          return { simulator_id = device.id, simulator_name = device.title }
        end
      end
      fail("The selected Simulator is no longer available.")
    elseif selected == "phone" then
      local phone = require_phone()
      local project = current_project(ctx)
      if not project then
        return
      end
      local window = open_window(
        "terminal-phone: work",
        project,
        { phone, "view", "work", "--protocol", "kitty" }
      )
      return { window_id = window.window_id, phone = "work" }
    elseif selected == "logs" then
      local phone = require_phone()
      local project = current_project(ctx)
      if not project then
        return
      end
      local window = open_window(
        "iOS Simulator Logs",
        project,
        { phone, "logs", "work", "--all" }
      )
      return { window_id = window.window_id, phone = "work" }
    elseif selected == "screenshot" then
      local phone = require_phone()
      local screenshot = "/tmp/ios-simulator-" .. tostring(os.time()) .. ".png"
      local result, err = rex.exec({
        phone, "action", "default", "screenshot", "--output", screenshot,
      }, { timeout = 20 })
      if not result then
        fail("Could not capture a Simulator screenshot: " .. tostring(err))
      end
      if not result.ok then
        fail("Could not capture a Simulator screenshot: " .. output_of(result))
      end
      rex.log("info", "Simulator screenshot saved to " .. screenshot)
      return { screenshot_path = screenshot }
    elseif selected == "codex" then
      local project = current_project(ctx)
      if not project then
        return
      end
      local codex = executable("codex")
      local command = codex
        and { codex }
        or fallback_shell("codex was not found. Install it or add it to PATH, then run codex here.")
      if ctx.block_id then
        local split, err = rex.session.new_split({
          anchor_id = ctx.block_id,
          direction = "horizontal",
          side = "after",
          ratio = 0.6,
          focus = true,
          layout = terminal_block(project, command),
        })
        if not split then
          fail("Could not open a Codex pane: " .. tostring(err or "Rex returned no pane"))
        end
        if err then
          fail("Could not open a Codex pane: " .. tostring(err))
        end
        return { block_id = split.block_ids and split.block_ids[1], project_path = project }
      end
      local window = open_window("Codex", project, command)
      return { window_id = window.window_id, project_path = project }
    end
  end,
})

rex.bind("cmd+shift+i", "ios_workspace")
rex.bind("ctrl+shift+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+shift+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+shift+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+shift+l", "pane.focus", { direction = "right" })
