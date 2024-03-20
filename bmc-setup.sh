#! /bin/bash
#

warning() {
    echo "Warning: $@"
}

error() {
    echo "Error: $@"
}

echo_task() {
    echo
    echo "** Task: $@ **"
    echo
}

install_prereqs() {
    echo_task "Install prerequisites"
sudo apt install git python3-distutils gcc g++ make file wget gawk diffstat bzip2 cpio chrpath zstd lz4 bzip2
}

bmc_dir=""

clone_obmc() {
    if [ "$OBMC_GIT" == "" ]; then
        error "Openbmc github repository is not given"
        exit 1
    fi
    git clone $OBMC_GIT
}

build_bmc_img() {
    target=$1
    if [ "$target" == "" ]; then
        error "no build target given"
        exit 1
    fi
    . setup $target
    bitbake obmc-phosphor-image
}


vars_file=".vars.config"

if [ ! -f "$vars_file" ];then
    error "vars file is not found."
    exit 1
fi

parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -Q|--qemu_root) QEMU_ROOT="$2"; shift ;;
            -K|--kernel_root) KERNEL_ROOT="$2"; shift ;;
            --image) image_name="$2"; shift ;;
            --install-ndctl) install_ndctl=true ;;
            --qemu-url) qemu_url=$2; shift ;;
            --kernel-url) kernel_url=$2; shift ;;
            -P|--port) ssh_port="$2"; shift ;;
            -L|--login) login=true ;;
            -R|--run) run=true ;;
            --reset) reset=true ;;
            --poweroff|--shutdown) shutdown=true ;;
            -F|--vars-file) opt_vars_file="$2"; shift;;
            -H|--help) help; exit;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
        shift
    done
}

parse_args "$@"
