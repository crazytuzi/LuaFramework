--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/7/17
-- Time: 14:07


if _G.isUseOldLogin then
	_dofile 'src/module/login/old/CreateRoleView.lua'
	_dofile 'src/module/login/old/LoginWaitView.lua'
	_dofile 'src/module/login/old/LoginScene.lua'
	_dofile 'src/module/login/old/LoginPlayer.lua'
else
	_dofile 'src/module/login/CreateRoleView.lua'
	_dofile 'src/module/login/LoginWaitView.lua'
	_dofile 'src/module/login/LoginScene.lua'
	_dofile 'src/module/login/LoginPlayer.lua'
end
_dofile 'src/module/login/LoginView.lua'
_dofile 'src/module/login/LoginController.lua'
_dofile 'src/module/login/LoginModel.lua'
_dofile 'src/module/login/WelcomeView.lua'
_dofile 'src/module/login/ServerFullView.lua'
--_dofile	'src/module/consol/ConsolController.lua'