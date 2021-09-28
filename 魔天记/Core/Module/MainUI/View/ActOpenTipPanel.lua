local ActOpenTipPanel = class("ActOpenTipPanel");

function ActOpenTipPanel:SetActive(active)
    if active then
    	if self.gameObject.activeSelf == false then
        	self.gameObject:SetActive(true);
    	end
    else
    	if self.gameObject.activeSelf then
        	self.gameObject:SetActive(false);
    	end
    end
end

local configs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_ACTIVITY);
function ActOpenTipPanel:Init(transform)
	self.transform = transform;
    self.gameObject = transform.gameObject;

    self.txtName = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtName");
    self.txtContent = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtContent");
    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");

    self.effect = UIUtil.GetChildByName(self.gameObject, "Transform", "ui_activity_opening");
    self.effect.gameObject:SetActive(false);

    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    self:SetActive(false);

    self.cfgs = {};
    
    for k,v in pairs(configs) do
    	if v.is_preview > 0 and #v.preview_schedule > 0 then
    		for i, tStr in ipairs(v.preview_schedule) do
    			--log(tStr);
    			local tArr = string.split(tStr,"_");
	    		local showTime = string.split(tArr[1], ":");
	    		local cdTime = string.split(tArr[2], ":");
	    		local sTime = string.split(tArr[3], ":");
	    		local eTime = string.split(tArr[4], ":");
	    		local d = {
	    			id = v.id,
	    			w = v.active_date,
	    			showTime = {h = tonumber(showTime[1]), m = tonumber(showTime[2])},
	    			cdTime = {h = tonumber(cdTime[1]), m = tonumber(cdTime[2])},
	    			sTime = {h = tonumber(sTime[1]), m = tonumber(sTime[2])},
	    			eTime = {h = tonumber(eTime[1]), m = tonumber(eTime[2])},
	    		};
	    		table.insert(self.cfgs, d);
    		end
    	end
    end

    self._timer = Timer.New( function(val) self:Check() end, 1, -1, false);
    self._timer:Start();
end

function ActOpenTipPanel:Dispose()
    
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClick = nil;

	self.gameObject = nil;

    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
end

function ActOpenTipPanel:SceneChange(isInField)

    self.isInField = isInField;

    self:Check();

end

function ActOpenTipPanel:Check()

	self.isOpen = false;

	if SystemManager.IsOpen(SystemConst.Id.ActTipsOpen) and self.isInField then
		local data = nil;
		local now = os.date("*t", GetTime());

		--Warning(now.hour .. " : " .. now.min);
		for k, v in pairs(self.cfgs) do
			if table.contains(v.w, now.wday) then
				--Warning(v.showTime.h .. ":" .. v.showTime.m .. " - " .. v.eTime.h .. ":" .. v.eTime.m )
				if ActOpenTipPanel.InTime(now, v.showTime) == false and ActOpenTipPanel.InTime(now, v.eTime)then
					--Warning(v.id);
					data = v;
					break;
				end					
			end			
		end

		if data then
			self.data = data;
			self:SetActive(true);
			self.effect.gameObject:SetActive(false);
			local cfg = configs[data.id];
			if self.lastCfg ~= cfg then
				self.lastCfg = cfg;
				self.txtName.text = cfg.activity_name;
				self.icon.spriteName = cfg.activity_icon;
	            self.icon:MakePixelPerfect();
        	end

			if ActOpenTipPanel.InTime(now, data.cdTime) then
				--预告阶段
				self.txtContent.text = LanguageMgr.Get("MainUI/ActOpen/1", {time = string.format("%.2d:%.2d", data.sTime.h, data.sTime.m)});
			elseif ActOpenTipPanel.InTime(now, data.sTime) then
				--倒数阶段
				local min = (data.sTime.h - now.hour) * 60 + data.sTime.m - now.min;
				local sec = min * 60 - now.sec;

				local m = math.floor(sec / 60);
        		local s = math.floor(sec - (m * 60));
				self.txtContent.text = LanguageMgr.Get("MainUI/ActOpen/2", {m = m, s = s});
			else
				--开始阶段
				self.txtContent.text = LanguageMgr.Get("MainUI/ActOpen/3");
				self.isOpen = true;
				self.effect.gameObject:SetActive(true);
			end

			return;
		end
	end

	self:SetActive(false);
end

function ActOpenTipPanel:_OnClick()
	if self.data then
		if self.isOpen then
			local cfg = configs[self.data.id];
			if PlayerManager.GetPlayerLevel() >= cfg.min_lev then
				ActivityDataManager.ActiveDo(self.data.id);
			else
				MsgUtils.ShowTips("MainUI/ActOpen/lev", {lev = cfg.min_lev});
			end
		else
			ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY_TIP, self.data.id);
		end	
	end
end

function ActOpenTipPanel.InTime(now, date)
	if now.hour == date.h then
		return now.min < date.m;
	else
		return now.hour < date.h;
	end
end

return ActOpenTipPanel;