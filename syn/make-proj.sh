#!/bin/bash
set -o errexit

function print_usage() {
	echo "
Usage: $0 [OPTION] PROJ_NAME

Description:
 Prepare an empty project directory. Optionally takes the project name as an
 argument. When no project name is passed it, the script defaults to 'tmp'.

Options:
 -h	Print this help info.

 -c	Commit the project directory into the repo.
"
}

# command line options
flag_c=
while getopts "hc" flag
do
	case "$flag" in
		c) flag_c=1;;
		h) print_usage; exit 1;;
		?) print_usage; exit 2;;
	esac
done

# set project name
PROJ=tmp;
if [ ! -z ${@:$OPTIND:1} ]; then
	PROJ=${@:$OPTIND:1};
fi

# if tmp.tcl file exists delete it
test -e ./tmp.tcl && rm ./tmp.tcl


if [ -z "$(command -v vivado)" ]; then
	echo "ERROR: No Xilinx tool has been sourced."
	exit 1
fi


# create a temporary tcl script that will be used by vivado
echo "
create_project $PROJ ./project-$PROJ -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.0 [current_project]
" > tmp.tcl

# run vivado to create the project
vivado -mode batch -nolog -nojournal -source tmp.tcl

# remove temporary tcl script
rm ./tmp.tcl

# if 'c' option selected 'commit' the project file to the repo
if [ ! -z "$flag_c" ]; then
	git add project-$PROJ
	git commit -m "Add empty Xilinx project '${PROJ}'"
fi
