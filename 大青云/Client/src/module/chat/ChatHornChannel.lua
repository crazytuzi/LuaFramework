--[[
聊天,喇叭频道
lizhuangzhuang
2014年10月8日14:33:43
]]

_G.ChatHornChannel = setmetatable({},{__index=ChatChannel});

ChatHornChannel.MIN_TIME = 1000;

--是否正在显示喇叭
ChatHornChannel.isShowHorn = false;

--经过时间
ChatHornChannel.time = 0;
--总时间
ChatHornChannel.totalTime = -1;

--添加聊天
function ChatHornChannel:AddChat(chatVO)
	table.push(self.chatList,chatVO);
	if #self.chatList == 1 then
		self:ShowNext();
	elseif #self.chatList > 1 then
		self.totalTime = ChatHornChannel.MIN_TIME;
	end
end


function ChatHornChannel:Update(interval)
	if self.totalTime < 0 then return; end
	self.time = self.time + interval;
	if self.time >= self.totalTime then
		self:ShowNext();
	end
end

function ChatHornChannel:ShowNext()
	if #self.chatList <= 0 then
		UIChat:HideHorn();
		self.totalTime = -1;
		return; 
	end
	local chatVO = table.remove(self.chatList,1);
	local duration = ChatHornChannel.MIN_TIME;
	local hornCfg = t_horn[chatVO.hornId];
	if hornCfg then
		duration = hornCfg.duration;
	end
	if #self.chatList > 0 then
		duration = ChatHornChannel.MIN_TIME;
	end
	self.time = 0;
	self.totalTime = duration;
	UIChat:ShowHorn(chatVO:GetText());
	-- 高级喇叭飘花瓣特效
	if chatVO.hornId == 110630003 then
		local winW,winH = UIManager:GetWinSize();
		local pos = {};
		pos.x = (winW - 1038) * 0.5
		pos.y = (winH - 826) * 0.5
		UIEffectManager:PlayEffect( ResUtil:GetFlowerEffect(), pos )
	end
end