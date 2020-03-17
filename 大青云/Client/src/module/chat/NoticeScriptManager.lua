--[[
公告脚本管理器
lizhuangzhuang
2014年9月18日20:19:53
]]
_G.classlist['NoticeScriptManager'] = 'NoticeScriptManager'
_G.NoticeScriptManager = {};
NoticeScriptManager.objName = 'NoticeScriptManager'
function NoticeScriptManager:DoScript(name,paramlist)
	if not NoticeScriptCfg[name] then
		print("Error:没有找到公告脚本,name="..name);
		return;
	end
	local script = NoticeScriptCfg[name];
	local result = false;
	if paramlist then
		result = script.execute(unpack(paramlist));
	else
		result = script.execute();
	end
	if not result then
		print("Error:公告脚本使用出错,name="..name);
	end
end