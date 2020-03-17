--[[
gm  view 
wangshuai
]]

_G.GMView = BaseUI:new("GMView")

function GMView:Create()
	self:AddSWF("toolsSuperInstructionPanel.swf",true,"center")
end

function GMView:OnLoaded(objSwf)
	objSwf.closepanle.click = function()self:Hide()end

	objSwf.gmlist.inputGmClick = function(e) self:OnInputClick(e)end;
end;

function GMView:OnShow()
	self:ShowList()
end;

function GMView:OnHide()

end;

function GMView:OnInputClick(e)
	local id = e.item.id;
	if not id then return end;
	local cfg = GMCfg[id]
	if cfg.execute then
		cfg.execute();
	else
		for i,info in ipairs(cfg.gmTxt) do 
			ChatController:SendChat(ChatConsts.Channel_World,info)  ---发送聊天信息
		end
	end
end

function GMView:ShowList()
	local objSwf =self.objSwf;
	local list = GMCfg;
	local gmlist = {};
	for i,info in ipairs(list) do 
		local gmvo = {};
		gmvo.id = i;
		gmvo.desc = info.txt;
		table.push(gmlist,UIData.encode(gmvo))
	end;
	objSwf.gmlist.dataProvider:cleanUp();
	objSwf.gmlist.dataProvider:push(unpack(gmlist));
	objSwf.gmlist:invalidateData();
end;