# Setup tab completion for zynq-axis repo scripts
#
# Move this "zynq-axis-completion.bash" file into your home directory and save
# it as a 'dot' file. Then add the following code snippet into your dot bashrc
# file.
<<"BASHRC_CODE"

if [ -f ~/.zynq-axis-completion.bash ]
then
	source ~/.zynq-axis-completion.bash
fi

BASHRC_CODE


_pkg-module_complete() {
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local completions="$(find hdl/ -type f \( -name "*.v" ! -name "*_tb.v" \) \
		-exec basename {} .v \; | xargs echo)"

	COMPREPLY=( $(compgen -W "$completions" -- "$cur") )
}
complete -F _pkg-module_complete pkg-module


_sim-module_complete() {
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local completions="$(find hdl/ -type f \( -name "*.v" ! -name "*_tb.v" \) \
		-exec basename {} .v \; | xargs echo)"

	COMPREPLY=( $(compgen -W "$completions" -- "$cur") )
}
complete -F _sim-module_complete sim-module


_syn-proj_complete() {
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"

	# completing an option
	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W "-h -s" -- $cur ) )
	else
		local completions="$(find syn/ -maxdepth 1 -type d -name "project-*" \
			-exec basename {} \;)"

		COMPREPLY=( $(compgen -W "$completions" -- "$cur") )
	fi
}
complete -F _syn-proj_complete syn-proj


_syn-proj-prep_complete() {
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"

	# completing an option
	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $( compgen -W "-c -h -l -L" -- $cur ) )
	fi
}
complete -F _syn-proj-prep_complete syn-proj-prep
