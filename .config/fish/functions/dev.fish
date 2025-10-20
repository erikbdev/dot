function dev --description "Run project in an isolated container"
    argparse "dockerfile=" "dockerpath=" "d/debug=?" h/help -- $argv
    or return

    if set -q _flag_help
        echo 'Usage: dev <options>

OPTIONS:
    --dockerfile    The Dockerfile to use (default: Dockerfile)
    --dockerpath    The path of docker (or podman)
'
        return 1
    end

    set dockerfile $_flag_dockerfile[-1]
    if test -z $dockerfile
        set dockerfile Dockerfile
    end

    set current_dir (pwd)
    set dir_name (basename $current_dir)
    set dir_hash (echo -n $folder | sha256sum | cut -d' ' -f1)

    set image $dir_name-$dir_hash
    set container $image

    if set -q _flag_debug
        echo "current_dir '$current_dir', dir_name '$dir_name', dir_hash '$dir_hash', image = '$image', container '$container', dockerfile '$dockerfile', dockerpath '$dockerpath'"
    end

    # build image
    if not test -e "$dockerfile"
        echo "Error: Dockerfile '$dockerfile' not found."
        return 1
    end
    echo "Building image: $image"
    podman build -t "$image" -f "$dockerfile" "$current_dir"
    or return 1

    echo "Creating and starting container $container"

    podman run -it \
        --name $container \
        --hostname $dir_name \
        -v $current_dir:/workspace:Z \
        --user 1000:1000 \
        -w /workspace \
        --replace \
        --entrypoint bash \
        $image
end
