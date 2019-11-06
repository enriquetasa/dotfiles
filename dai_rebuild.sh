echo "ps -ef | grep ".vscode-server" | xargs kill"
echo "ls core.* | xargs rm"
echo "sm_sysman noninteractive shutdown && ut_sys_build && sm_startup --yes-to-all"
