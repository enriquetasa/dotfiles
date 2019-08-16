pgrep -f ".vscode-server/bin" | xargs kill
ls core.* | xargs rm
sm_sysman noninteractive shutdown && ut_sys_build && sm_startup --yes-to-all
