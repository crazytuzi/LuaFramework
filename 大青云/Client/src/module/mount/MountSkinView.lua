--[[坐骑进阶界面
zhangshuhui
2014年11月05日17:20:20
]]

_G.UIMountSkin = BaseUI:new("UIMountSkin")

--剩余的秒数
UIMountSkin.timelast = 0;
--剩余时间定时器key
UIMountSkin.lastTimerKey = nil;

--当前皮肤id
UIMountSkin.selid = 0;


UIMountSkin.ListLength = 6;
UIMountSkin.ItemWidth = 169;
UIMountSkin.TweenTime = 0.5;

UIMountSkin.skinlist = {};

function UIMountSkin:Create()
	self:AddSWF("mountSkinPanel.swf", true, "center")
end

local mountskinmouseMoveX = 0
function UIMountSkin:OnLoaded(objSwf,name)
	self:Init(objSwf);
	objSwf.list.itemClick1 = function(e) self:OnListItemClick(e); end
	objSwf.btnRide.click    = function() self:OnBtnRideClick(); end
	objSwf.getpanel.btnactiveinfo.rollOver = function() self:OnActiveInfoRollOver(); end
	objSwf.getpanel.btnactiveinfo.rollOut  = function()  TipsManager:Hide(); end
	
	objSwf.yishiyongeffect.complete = function()
									objSwf.imgrided._visible = true;
								end
								
	objSwf.btnDesShow.press = function() 		
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		mountskinmouseMoveX = monsePosX;   		       
		self.isMouseDrag = true
	end

	objSwf.btnDesShow.release = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("release"); 				
		end
	end
end

function UIMountSkin:Init(objSwf)
	objSwf.modelload.hitTestDisable  = true;
end

function UIMountSkin:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIMountSkin:Update()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.bShowState then return end
	
	if self.isMouseDrag then
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		if mountskinmouseMoveX<monsePosX then
			local speed = monsePosX - mountskinmouseMoveX
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleRightStateChange("down",speed); 
			end
		elseif mountskinmouseMoveX>monsePosX then 
			local speed = mountskinmouseMoveX - monsePosX
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleLeftStateChange("down",speed); 
			end
		end
		mountskinmouseMoveX = monsePosX;
	end
	
	local cfg = {};
	if self.selid < MountConsts.SpecailDownid then
		cfg = t_horse[self.selid];
		
		if not cfg then
			Error("Cannot find config of horse. level:"..self.selid);
			return;
		end
	elseif self.selid < MountConsts.LingShouSpecailDownid then
		cfg = t_horseskn[self.selid];
		
		if not cfg then
			Error("Cannot find config of t_horseskn. level:"..self.selid);
			return;
		end
	end
	
	
	local ui_node =  MountUtil:GetMountSen(cfg.ui_node,MainPlayerModel.humanDetailInfo.eaProf);
	
	if self.objUIDraw then
		self.objUIDraw:Update(ui_node);
	end
end

function UIMountSkin:OnShow(name)
	--初始化数据
	self:InitData();
	self:UpdateShow();
	self:StartLastTimer();
end

function UIMountSkin:OnHide()
	self:DelTimerKey();
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIMountSkin:GetWidth()
	return 1489;
end

function UIMountSkin:GetHeight()
	return 760;
end

function UIMountSkin:OnSkinChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ShowSkin();
end

function UIMountSkin:HandleNotification(name)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.MountRidedChanged then
		self:PlayYiShiYongEffect();
	elseif name == NotifyConsts.MountSkinTimeUpdate then
		self:UpdateSkinList();
		self:ShowSkinInfo();
	elseif name == NotifyConsts.BagItemNumChange then
		self:UpdateActiveInfo();
	end
end

function UIMountSkin:ListNotificationInterests()
	return {NotifyConsts.MountRidedChanged,NotifyConsts.MountRidedChangedState,
			NotifyConsts.MountSkinTimeUpdate};
end

function UIMountSkin:OnActiveInfoRollOver()
	if not self.selid then
		return;
	end
	local skncfg = t_horseskn[self.selid];
	if not skncfg then
		return;
	end
	local itemid = tonumber(skncfg.active_con);
	if self.selid > MountConsts.SpecailDownid  and self.selid < MountConsts.LingShouSpecailDownid then
		local itmevo = t_item[itemid];
		if itmevo then
			TipsManager:ShowItemTips(itemid);
		end
	end
end

function UIMountSkin:InitData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self.selid = 1;
	
	self.openlist = {};
	local vo1 = {};
	vo1.label1 = 1;
	table.push(self.openlist, vo1);
	local vo2 = {};
	vo2.label1 = 1;
	vo2.label2 = 1;
	table.push(self.openlist, vo2);
	local vo3 = {};
	vo3.label1 = 2;
	table.push(self.openlist, vo3);
	local vo4 = {};
	vo4.label1 = 3;
	table.push(self.openlist, vo4);
end

function UIMountSkin:UpdateShow()
	self:UpdateSkinList();
	self:ShowSkin();
end

function UIMountSkin:UpdateSkinList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local treeData = MountUtil:GetMountSkinList(self.openlist);
	if not treeData then return; end
	UIData.cleanTreeData( objSwf.list.dataProvider.rootNode);
	UIData.copyDataToTree(treeData,objSwf.list.dataProvider.rootNode);
	objSwf.list.dataProvider:preProcessRoot();
	objSwf.list:invalidateData();
end

function UIMountSkin:ShowSkin()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ShowSkinAttrInfo(self.selid);
	self:ShowSkinInfo(self.selid);
	self:PlayMountSound(self.selid);
	self:Show3DSkin(self.selid);
end

local viewMountSkinPort;
function UIMountSkin:Show3DSkin(skinId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local modelId = MountUtil:GetPlayerMountModelId(skinId)
	local modelCfg = t_mountmodel[modelId];
	if not modelCfg then
		Error("Cannot find config of MountModel. skinId:"..modelId);
		return;
	end
	local san_show = modelCfg.san_show;
	local cfg = {};
	--普通坐骑
	if skinId < MountConsts.SpecailDownid then
		cfg = t_horse[skinId];
		if not cfg then
			Error("Cannot find config of horse. level:"..skinId);
			return;
		end
	elseif skinId < MountConsts.LingShouSpecailDownid then
		cfg = t_horseskn[skinId];
		if not cfg then
			Error("Cannot find config of horseskn. level:"..skinId);
			return;
		end
	end
	
	if not self.objUIDraw then
		if not viewMountSkinPort then viewMountSkinPort = _Vector2.new(1500, 800); end
		self.objUIDraw = UISceneDraw:new( "UIMountSkin", objSwf.modelload, viewMountSkinPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	
	local sen = MountUtil:GetMountSen(cfg.ui_sen,MainPlayerModel.humanDetailInfo.eaProf);
	local ui_node =  MountUtil:GetMountSen(cfg.ui_node,MainPlayerModel.humanDetailInfo.eaProf);
	
	if sen and sen ~= "" then
		--self.objUIDraw:SetScene( sen, nil );
		self.objUIDraw:SetScene( sen, function()
			local aniName = san_show;
			if not aniName or aniName == "" then return end
			if not cfg.ui_node then return end
			local nodeName = split(ui_node, "#")
			if not nodeName or #nodeName < 1 then return end
				
			for k,v in pairs(nodeName) do
				self.objUIDraw:NodeAnimation( v, aniName );
			end
		end );
		self.objUIDraw:SetDraw( true );
	end
end

function UIMountSkin:ShowSkinAttrInfo(skinId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if skinId < MountConsts.SpecailDownid or skinId > MountConsts.LingShouSpecailDownid then
		objSwf.skinattr._visible = false;
		objSwf.txt_noPro._visible = false
		objSwf.arrtbg._visible=false;

		return;
	end
	objSwf.txt_noPro._visible = false
    objSwf.arrtbg._visible=true;
	objSwf.skinattr._visible = true;
	
	local info = MountUtil:GetMountSkinAttribute(skinId);
	if info == nil then
		return
	end
	for i=1,7 do
	    local textField = objSwf.skinattr["txtAttr"..i];
            if textField then 
        	    textField.htmlText =0;
            end
	end
	objSwf.skinattr.lableother.text = "";
	objSwf.skinattr.tfHorseAttAdd.text = "";
	for i = 9, 15 do
		objSwf.skinattr["tfName"..i].htmlText = PublicStyle:GetAttrNameStr(UIStrConfig["mount"..i]);
	end
	trace(info)
	print(enAttrType.eaGongJi,enAttrType.eaFangYu,enAttrType.eaMaxHp,enAttrType.eaBaoJi,enAttrType.eaRenXing,enAttrType.eaMingZhong,enAttrType.eaShanBi)
	for i,vo in ipairs(info) do
        local textField = objSwf.skinattr["txtAttr"..i];
        if textField then 
        	textField.htmlText =PublicStyle:GetAttrValStr(vo.val);
	    else
	    	objSwf.skinattr.lableother.text = enAttrTypeName[vo.type]..":";
		    objSwf.skinattr.tfHorseAttAdd.text = getAtrrShowVal(vo.type, vo.val);
        end
		-- if vo.type == enAttrType.eaGongJi then
		-- 	objSwf.skinattr.tfGongJiAdd.htmlText = PublicStyle:GetAttrValStr(vo.val)
		-- elseif vo.type == enAttrType.eaFangYu then
		-- 	objSwf.skinattr.tfFangYuAdd.htmlText = PublicStyle:GetAttrValStr(vo.val)
		-- elseif vo.type == enAttrType.eaMaxHp then
		-- 	objSwf.skinattr.tfShengMingAdd.htmlText = PublicStyle:GetAttrValStr(vo.val)
		-- elseif vo.type == enAttrType.eaBaoJi then
		-- 	objSwf.skinattr.tfBaoJiAdd.htmlText = PublicStyle:GetAttrValStr(vo.val)
		-- elseif vo.type == enAttrType.eaRenXing then
		-- 	objSwf.skinattr.tfRenXingAdd.htmlText = PublicStyle:GetAttrValStr(vo.val)
		-- elseif vo.type == enAttrType.eaShanBi then
		-- 	objSwf.skinattr.tfShanBiAdd.htmlText = PublicStyle:GetAttrValStr(vo.val)
		-- elseif vo.type == enAttrType.eaMingZhong then
		-- 	objSwf.skinattr.tfMingZhongAdd.htmlText = PublicStyle:GetAttrValStr(vo.val)
		-- else
		-- end
	end
end

function UIMountSkin:ShowSkinInfo(skinId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	skinId = self.selid;
	--名称
	local playerinfo = MainPlayerModel.humanDetailInfo;	
	local iconname = MountUtil:GetMountIconName(skinId, "nameIcon", playerinfo.eaProf)
	
	--骑乘按钮
	self:ShowBtnRide(skinId);
	
	self:UpdateActiveInfo();
end

function UIMountSkin:UpdateActiveInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--获取条件
	objSwf.getpanel._visible = false;
	objSwf.getpanel.tfgetinfo.text = "";
	objSwf.getpanel.btnactiveinfo.htmlLabel = "";
	objSwf.imgnotget._visible = false;
	--普通坐骑
	if self.selid < MountConsts.SpecailDownid then
		if MountModel.ridedMount.mountLevel < self.selid then
			objSwf.getpanel._visible = true;
			objSwf.getpanel.tfgetinfo.text = t_horse[self.selid].active_con;
			
			objSwf.imgnotget._visible = true;
		end
	elseif self.selid < MountConsts.LingShouSpecailDownid then
		if MountUtil:GetMountTime(self.selid) == 0 then
			objSwf.imgnotget._visible = true;
			local list = split(t_horseskn[self.selid].active_type, ",")
			if #list == 1 then
				local itemid = tonumber(t_horseskn[self.selid].active_con);
				if itemid then
					local intemNum = BagModel:GetItemNumInBag(itemid);
					local stritem = "";
					if intemNum > 0 then
						stritem = "<font color='#00ff00'><u>"..t_item[itemid].name.."</u></font>";
					else
						stritem = "<font color='#cc0000'><u>"..t_item[itemid].name.."</u></font>";
					end
					objSwf.getpanel._visible = true;
					objSwf.getpanel.btnactiveinfo.htmlLabel = string.format( StrConfig["mount34"], stritem)
				end
			else
				objSwf.getpanel._visible = true;
				objSwf.getpanel.tfgetinfo.text = list[2];
			end
		end
	end
end

--更新信息
function UIMountSkin:ShowBtnRide(skinId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	skinId = skinId or self.selid;
	if not skinId then return; end
	
	objSwf.btnRide.visible = false;
	objSwf.imgrided._visible = false;
	objSwf.yishiyongeffect:stopEffect();
	objSwf.yishiyongeffect._visible = false;
	
	if (skinId < MountConsts.SpecailDownid and MountModel.ridedMount.mountLevel >= skinId) or
	   ((skinId >= MountConsts.SpecailDownid and skinId < MountConsts.LingShouSpecailDownid) and MountUtil:GetMountTime(skinId) ~= 0) or
		(skinId > MountConsts.LingShouSpecailDownid and MountLingShouModel.mountLevel >= skinId)then
		if MountModel.ridedMount.ridedId == 0 then
			objSwf.btnRide.visible = true;
		elseif MountModel.ridedMount.ridedId == skinId then
			objSwf.imgrided._visible = true;
		else
			objSwf.btnRide.visible = true;
		end
	end
end

--更新信息
function UIMountSkin:PlayYiShiYongEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.yishiyongeffect:stopEffect();
	objSwf.yishiyongeffect._visible = false;
	
	if MountModel.ridedMount.ridedId == self.selid then
		objSwf.yishiyongeffect._visible = true;
		objSwf.yishiyongeffect:playEffect(1);
		objSwf.btnRide.visible = false;
	end
end

function UIMountSkin:OnBtnRideClick()
	--更换坐骑
	MountController:ChangeMount(self.selid);
end

function UIMountSkin:OnbtnBgRollOver(k)
end

function UIMountSkin:OnbtnBgRollOut(e, k)
end
	
--预览
function UIMountSkin:OnBtnPreviewClick(k)
end

function UIMountSkin:OnBtnLightOver(k)
end

function UIMountSkin:OnBtnLightOut(k)
end

--点击列表
function UIMountSkin:OnListItemClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not e.item then return; end
	
	local lvl = e.item.lvl;
	if  lvl == 2 then
		self.selid = e.item.id;
		self:ShowSkin();
	end
	
	self:UpdateOpenList(e.item);
	self:UpdateSkinList();
end

function UIMountSkin:PlayMountSound(skinId)
	local soundid = MountUtil:GetMountSound(skinId,MainPlayerModel.humanDetailInfo.eaProf);
	if soundid > 0 then
		SoundManager:StopSfx();
		SoundManager:PlaySfx(soundid);
	end
end

function UIMountSkin:UpdateOpenList(node)
	--如果是第2层，需要先删除其他的第2层显示item，在添加node
	local ischild = false;
	if node.lvl == 2 then
		ischild = true;
	end
	local isfind = false;
	for i,vo in pairs(self.openlist) do
		if vo then
			--是否有选中2层
			if ischild == true then
				if vo["label"..node.lvl] then
					isfind = false;
					self.openlist[i] = {};
					break;
				end
			end
		
			local ishave = true;
			for i=1,2 do
				if node["label"..i] and vo["label"..i] then
					if node["label"..i] ~= vo["label"..i] then
						ishave = false;
						break;
					end
				elseif (not node["label"..i] and vo["label"..i]) or (node["label"..i] and not vo["label"..i]) then
					ishave = false;
					break;
				end
			end
			
			if ishave == true then
				isfind = true;
				self.openlist[i] = {};
				break;
			end
		end
	end
	
	--添加
	if isfind == false then
		local vo = {};
		for i=1,2 do
			if node["label"..i] then
				vo["label"..i] = node["label"..i];
			end
		end
		table.push(self.openlist, vo);
	end
end

function UIMountSkin : DrawMount(modelid,nindex)
end;

function UIMountSkin:StartLastTimer()
	if self.lastTimerKey then
		TimerManager:UnRegisterTimer(self.lastTimerKey);
		self.lastTimerKey = nil;
	end
	
	self.lastTimerKey = TimerManager:RegisterTimer( self.DecreaseTimeLast, 100, 0 );
end

--倒计时自动
function UIMountSkin.DecreaseTimeLast( count )
	local objSwf = UIMountSkin.objSwf;
	if not objSwf then return; end
	
	local mounttime = MountUtil:GetMountTime(UIMountSkin.selid)
	
	--时间到了
	if mounttime <= 0 then
		objSwf.skinattr.tfTime.text = ''
		return
	end
	
	objSwf.skinattr.tfTime.text = UIMountSkin:GetDayHourMinute(mounttime)
end

--显示倒计时
function UIMountSkin:GetDayHourMinute(seconds)
	--永久
	if seconds <= 0  then
		return "";
	end
	
	local one_day = 60 * 60 * 24;
	local one_hour  = 60 * 60;
	local one_minute = 60;
	
	local day = seconds / one_day;
	day = day - day % 1
	local hour = seconds % one_day / one_hour;
	hour = hour - hour % 1
	local minute = seconds % one_day % one_hour /  one_minute;
	minute = minute - minute % 1
	local second = seconds % one_day % one_hour %  one_minute;
	second = second - second % 1
	
	return string.format( StrConfig['mount3'], day, hour, minute, second );
end

function UIMountSkin:DelTimerKey()
	if self.lastTimerKey then
		TimerManager:UnRegisterTimer( self.lastTimerKey );
		self.lastTimerKey = nil;
	end
end