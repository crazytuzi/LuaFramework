require "Core.Module.Common.Panel"
require "Core.Module.Message.View.Item.MessageTipsItem";
require "Core.Module.Message.View.Item.MessageMarqueeItem";
local MessageTipsItem2 = require "Core.Module.Message.View.Item.MessageTipsItem2";
require "Core.Module.Message.View.Item.AddAttrPanel"
require "Core.Module.Message.View.Item.MessageAlertItem"
require "Core.Module.Message.View.Item.FloatMessageTipItem";


MessagePanel = class("MessagePanel", Panel)
MessagePanel.MAXTIPS = 2;
local attrInterval = 0.35
local insert = table.insert
local MAX_PROPITEM = 7 --显示对象数
local MAX_CACHE = 8 --最多缓存条数
local PROPITEM_GAP = 14--新增条目时间间隔

function MessagePanel:IsFixDepth()
	return true;
end

function MessagePanel:IsPopup()
	return false;
end

function MessagePanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function MessagePanel:GetUIOpenSoundName()
	return ""
end

function MessagePanel:_InitReference()
	self._trsMarquee = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMarquee");
	self._trsMarqueeItem = UIUtil.GetChildByName(self._trsMarquee, "Transform", "item");
	self._marqueeItem = MessageMarqueeItem.New(self._trsMarqueeItem);
	
	self._trsAlert = UIUtil.GetChildByName(self._trsContent, "Transform", "trsAlert");
	self._trsAlertItem = UIUtil.GetChildByName(self._trsAlert, "Transform", "item");
	self._alertItem = MessageAlertItem.New(self._trsAlertItem);
	
	self._trsNoitce = UIUtil.GetChildByName(self._trsContent, "Transform", "trsNoitce");
	for i = 1, 3 do
		local trsNoticeItem = UIUtil.GetChildByName(self._trsNoitce, "Transform", "item" .. i);
		self["_noticeItem" .. i] = MessageTipsItem.New(trsNoticeItem);
	end
	
	--新版Tips效果
	self._newTipsItemNames = {[1] = "_newTipsItem1", [2] = "_newTipsItem2", [3] = "_newTipsItem3"}
	self._trsTips = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTips");
	for i = 1, 3 do
		local newTipsItem = UIUtil.GetChildByName(self._trsTips, "Transform", "item" .. i);
		self[self._newTipsItemNames[i]] = FloatMessageTipItem.New(newTipsItem);
	end
	self._checkNewTipsListTime = 0;
	self._newTipsList = {};
	
	self._trsFight = UIUtil.GetChildByName(self._trsContent, "Transform", "trsFight");
	self._txtFight = UIUtil.GetChildByName(self._trsFight, "UILabel", "txtFight");
	--self._icoStatus = UIUtil.GetChildByName(self._trsFight, "UISprite", "icoStatus");
	self._imgBg = UIUtil.GetChildByName(self._trsFight, "UISprite", "bg")
	self._trsFight.gameObject:SetActive(false);
	self._fightEffect = UIUtil.GetUIEffect("ui_zdl", self._trsFight, self._imgBg, 10)
	self._trsProps = UIUtil.GetChildByName(self._trsContent, "Transform", "trsProps");
    local pitem = UIUtil.GetChildByName(self._trsProps, "Transform", "item1")
    local pitemgo = pitem.gameObject
    local pitemp = pitem.parent
	for i = 1, MAX_PROPITEM do
		local trsPropItem = i == 1 and pitem or Resourcer.Clone(pitemgo, pitemp)
		self["_propItem" .. i] = MessageTipsItem2.New(trsPropItem);
	end

	self._trsTrumpet = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTrumpet");
	self._trsTrumpetItem = UIUtil.GetChildByName(self._trsTrumpet, "Transform", "item");
	self._trumpetItem = MessageTipsItem.New(self._trsTrumpetItem);

	self._marqueeList = {};
	self._noticeList = {};
	self._tipsList = {};
	self._propList = {};
	self._addAttrList = {}
	self._trumpetList = {}

	self._lastTime = 0
    self._propItemTime = 0 --新增条目时间

	UpdateBeat:Add(self.OnUpdate, self);
end

function MessagePanel:_InitListener()
	
end

function MessagePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function MessagePanel:_DisposeListener()
	
end

function MessagePanel:_DisposeReference()
	self._marqueeItem:Dispose();
	self._alertItem:Dispose()
	self._trumpetItem:Dispose();
	if self._fightEffect then
		Resourcer.Recycle(self._fightEffect, false);
		self._fightEffect = nil;
	end
	
	for i = 1, 3 do
		self["_noticeItem" .. i]:Dispose();
	end
	
	for i = 1, 3 do
		self[self._newTipsItemNames[i]]:Dispose();
		self[self._newTipsItemNames[i]] = nil;
		self._newTipsItemNames[i] = nil;
	end
	
	self._newTipsItemNames = nil;
	
	for i = 1, MAX_PROPITEM do
		self["_propItem" .. i]:Dispose();
	end
	
	UpdateBeat:Remove(self.OnUpdate, self);
	
end

function MessagePanel:OnUpdate()
	
	if self._gameObject.activeSelf == false then
		return;
	end
	local t = Time.deltaTime

	if(self._checkAddAttr) then
		self._lastTime = self._lastTime + t
		if(self._lastTime > attrInterval) then
			self._lastTime = 0
			if(#self._addAttrList > 0) then
				AddAttrPanel:New(self._addAttrList[1], self._trsContent)
				table.remove(self._addAttrList, 1)
			else
				self._checkAddAttr = false
			end
		end
		
	end
	
	if #self._marqueeList > 0 then
		local cur = self._marqueeList[1];
		if cur._time < 0 then
			table.remove(self._marqueeList, 1);
		elseif cur._time > 0 then
			self._marqueeItem:Show(cur);
		end
		
		if #self._marqueeList <= 0 then
			self._marqueeItem:Disable();
		end
	end

	if #self._trumpetList > 0 then
		local cur = self._trumpetList[1];
		cur._time = cur._time - t;

		if cur._time < 0 then
			table.remove(self._trumpetList, 1);
		elseif cur._time > 0 then
			self._trumpetItem:Show(cur);
		end
		
		if #self._trumpetList <= 0 then
			self._trumpetItem:Disable();
		end
	end
	
	if self._checkNotice then
		for i = 1, 3 do
			local v = self._noticeList[i];
			if v then
				v._time = v._time - t;
				if v._time < 0 then
					self["_noticeItem" .. i]:Disable();
					self._noticeList[i] = nil;
				end
			end
		end
		
		if self._noticeList[1] == nil and self._noticeList[2] == nil and self._noticeList[3] == nil then
			self._checkNotice = false;
		end
	end
	
	if self._checkTips then
		for i = 1, 3 do
			local v = self._tipsList[i];
			if v then
				v._time = v._time - t;
				if v._time < 0 then
					self["_tipsItem" .. i]:Disable();
					self._tipsList[i] = nil;
				end
			end
		end
		
		if self._tipsList[1] == nil and self._tipsList[2] == nil and self._tipsList[3] == nil then
			self._checkTips = false;
		end
	end
	
	if self.updateFightPower then
		local power = self._tempFight
		
		if power == self.fightPower then
			self.updateFightTime = self.updateFightTime - t;
			if self.updateFightTime < 0 then
				self.updateFightPower = false;
				self._trsFight.gameObject:SetActive(false);
			end
		else
			local val = math.max(math.abs((self.fightPower - power) / 10), 1);
			if self.fightPower > power then
				self._tempFight = math.floor(power + val);
			else
				self._tempFight = math.floor(power - val);
			end
			self._txtFight.text = "+" .. self._tempFight;
		end
	end
	
	if self._checkProps then
        self._propItemTime = self._propItemTime + 1
        if self._propItemTime > PROPITEM_GAP and #self._propList > 0 then
            for i = 1, MAX_PROPITEM do
                local pi = self["_propItem" .. i]
			    if not pi.enabled then
                    local pd = table.remove(self._propList)
                    pi:Show(pd)
                    self._propItemTime = 0
                    break
                end
		    end
        end
        local nop = true
        for i = 1, MAX_PROPITEM do
            local pi = self["_propItem" .. i]
			if pi.enabled then
                nop = false
                pi:UpdateShow(t)
            end
		end
		if nop and #self._propList == 0 then
			self._checkProps = false;
		end

--		for i = #self._propList, 1, - 1 do
--			local v = self._propList[i];
--			v._time = v._time - t;
--			if v._time < 0 then
--				self["_propItem" .. i]:Disable();
--				table.remove(self._propList, i);
--			end
--		end

--		if #self._propList == 0 then
--			self._checkProps = false;
--		end
	end
	
	if self._checkNewTipsItems then
		
		for i = 1, 3 do
			self[self._newTipsItemNames[i]]:Update(t);
		end
		
		self:_CheckShowNewTipsItems(t);
	end
end

function MessagePanel:ShowTips(data)
	self:_NewShowTips(data);
--[[    for i = 2, 1, -1 do
        if self._tipsList[i] then
            -- 上移
            local a = i + 1;
            self._tipsList[a] = self._tipsList[i];
            self["_tipsItem"..a]:Update(self._tipsList[a]);

            self["_trsTipsItem" .. a].localPosition = self._tipsPos[i];
            LuaDOTween.DOLocalMoveY(self["_trsTipsItem" .. a], self._tipsPos[a].y, 0.3, false)
        end
    end

    data._time = 2;
    -- 提示时间为2秒

    self._tipsItem1:Show(data);
    self._tipsList[1] = data;
    self._checkTips = true;
    ]]
end

function MessagePanel:ShowNotice(data)
	for i = 3, 2, - 1 do
		if self._noticeList[i - 1] then
			self._noticeList[i] = self._noticeList[i - 1];
			self["_noticeItem" .. i]:Update(self._noticeList[i]);
		end
	end
	
	data._time = 3;
	-- 炫耀公告时间为3秒
	self._noticeItem1:Show(data);
	self._noticeList[1] = data;
	self._checkNotice = true;
end

function MessagePanel:ShowMarquee(data)
	data._time = 1;
	insert(self._marqueeList, data);
end

function MessagePanel:ShowAddAttr(data)
	table.AddRange(self._addAttrList, data)
	self._checkAddAttr = true
end

-- 显示战斗力
function MessagePanel:UpdateFight(d)
	-- local new = PlayerManager.GetSelfFightPower();
	-- if new <= d then
	--     return;
	-- end
	if(d <= 0) then
		return
	end
	
	UIUtil.SetEffectOrder(self._fightEffect, self._imgBg)
	self.updateFightTime = 1;
	-- 变化完成后停留1秒.
	self._txtFight.text = "0";
	self._tempFight = 0
	self._trsFight.gameObject:SetActive(true);
	--self._icoStatus.spriteName = new > d and "up" or "down";
	self.fightPower = d;
	self.updateFightPower = true;
end

function MessagePanel:ShowAlert(data)
	self._alertItem:Show(data);
end

function MessagePanel:ShowProps(data)
	
	-- for i,v in ipairs(self._propList) do
	-- v.flag = 0
	-- end
--	for i, v in ipairs(data) do
--		v._time = 1;
--		-- 物品显示时间1秒
--		-- data[i].flag = 1;
--		insert(self._propList, 1, v);
--	end

--	for i = 1, 4 do
--		local v = self._propList[i];
--		if v then
--			-- if v.flag > 0 then
--			-- self["_propItem"..i]:Show(v);
--			-- else
--			self["_propItem" .. i]:Update(v);
--			-- end
--		end
--	end

--	while #self._propList > 4 do
--		table.remove(self._propList);
--	end

    local l = #data
    local pl = #self._propList
    local al = MAX_CACHE - pl
    local st = l - al
    if st < 1 then st = 1 end
	for i = st, l do --保留最新的
        local v = data[i]
		insert(self._propList, v);
	end

	self._checkProps = true;
end

function MessagePanel:ShowTrumpet(data)
	data._time = 5;
	if #self._trumpetList > 10 then
		table.remove(self._trumpetList, 1);
		
	end
	insert(self._trumpetList, data);
end

function MessagePanel:_NewShowTips(data)
	
	table.insert(self._newTipsList, 1, data);
	
	self._checkNewTipsItems = true;
	
	self:_CheckShowNewTipsItems(0);
end

function MessagePanel:_CheckShowNewTipsItems(deltaTime)
	
	self._checkNewTipsListTime = self._checkNewTipsListTime - deltaTime;
	local newTipsNum = #self._newTipsList;
	
	local newTipsItem = nil;
	local onPos0 = false;
	local index40 = 0;
	local index80 = 0;
	--更新在进行中的提示
	for i = 1, 3 do
		newTipsItem = self[self._newTipsItemNames[i]];
		if newTipsItem.FloatPosState > 0 then
			newTipsItem:UpdateLeftTipsNum(newTipsNum);
		end;
		--检测当前飘中的信息状态
		if newTipsItem.FloatPosState == 2 then
			onPos0 = true;
		elseif newTipsItem.FloatPosState == 3 then
			index40 = i;
		elseif newTipsItem.FloatPosState == 4 then
			index80 = i;
		end;
	end;
	
	if onPos0 and index40 > 0 then
		--通知次高位置的信息往上顶
		newTipsItem = self[self._newTipsItemNames[index40]];
		newTipsItem:SetMaxY(true);
		
		--通知最高位置的信息关闭
		if index80 > 0 then
			newTipsItem = self[self._newTipsItemNames[index80]];
			newTipsItem:Disable();
		end;
	end;
	
	if newTipsNum > 0 then
		local tips = self._newTipsList[newTipsNum];
		for i = 1, 3 do
			newTipsItem = self[self._newTipsItemNames[i]];
			if newTipsItem.FloatPosState == 0 and self._checkNewTipsListTime < 0 then
				
				newTipsItem:Show(tips, newTipsNum - 1);
				table.remove(self._newTipsList, newTipsNum);
				self._checkNewTipsListTime = 0.4;
				break;
			end;
		end;
	else
		--判断下是不是都已经飘完了
		self._checkNewTipsItems = false;
		for i = 1, 3 do
			if self[self._newTipsItemNames[i]].FloatPosState > 0 then
				self._checkNewTipsItems = true;
				break;
			end;
		end;
	end;
	
end; 