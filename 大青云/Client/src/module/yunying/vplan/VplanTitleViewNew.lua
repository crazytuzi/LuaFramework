--[[
	func:  V计划新称号
	author:houxudong
	date:  2016/11/21 12:24:36
]]

_G.UIVplanTitleNew = BaseUI:new('UIVplanTitleNew')

function UIVplanTitleNew:Create()
	self:AddSWF("vplanTitleNew.swf",true,nil);
end

function UIVplanTitleNew:OnLoaded(objSwf)
	objSwf.btn1.click = function () self:OnVOneClick(); end
	objSwf.btn2.click = function () self:OnVTwoClick(); end
	objSwf.btn3.click = function () self:OnVThreeClick(); end
end

function UIVplanTitleNew:OnShow()
	self:InintUiData()
end

-- 初始化界面信息
function UIVplanTitleNew:InintUiData( )
	-- 按钮操作
	self:InitBtnShowData()
	-- 称号信息
	self:InitTitleData()
end

-- 按钮操作
function UIVplanTitleNew:InitBtnShowData( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- 我的V等级
	local myVLevel = VplanModel:GetVPlanLevel()
	-- 对应称号奖励领取状态
	local myVOneRewardState   = VplanModel:GetLowTitle( )   -- 我的V1领取状态
	local myVMidRewardState   = VplanModel:GetMidTitle( )   -- 我的V23领取状态
	local myVThreeRewardState = VplanModel:GetHighTitle( )  -- 我的V45领取状态
	if myVLevel == 1 then
		for i=1,3 do
			objSwf['btn'..i]._visible = true
			objSwf['btn'..i].disabled = true
			objSwf['ling_'..i]._visible = false
			if i == 1 then
				if myVOneRewardState then  --v1奖励未领取
					objSwf.btn1._visible = true
					objSwf.btn1.disabled = false
					objSwf.ling_1._visible = false
				else
					objSwf.btn1._visible = false
					objSwf.btn1.disabled = true
					objSwf.ling_1._visible = true
				end
			end
		end
	elseif myVLevel >= 2 and myVLevel <= 3 then
		for i=1,3 do
			if i == 1 then
				if myVOneRewardState then  --v1奖励未领取
					objSwf.btn1._visible = true
					objSwf.btn1.disabled = false
					objSwf.ling_1._visible = false
				else
					objSwf.btn1._visible = false
					objSwf.btn1.disabled = true
					objSwf.ling_1._visible = true
				end
			end
			if i == 2 then
				if myVMidRewardState then  --v(2-3)奖励未领取
					objSwf.btn2._visible = true
					objSwf.btn2.disabled = false
					objSwf.ling_2._visible = false
				else
					objSwf.btn2._visible = false
					objSwf.btn2.disabled = true
					objSwf.ling_2._visible = true
				end
			end
			if i == 3 then
				objSwf['btn'..i]._visible = true
				objSwf['btn'..i].disabled = true
				objSwf['ling_'..i]._visible = false
			end
		end
	elseif myVLevel >= 4 and myVLevel <= 5 then
		for i=1,3 do
			if i == 1 then
				if myVOneRewardState then  --v1奖励未领取
					objSwf.btn1._visible = true
					objSwf.btn1.disabled = false
					objSwf.ling_1._visible = false
				else
					objSwf.btn1._visible = false
					objSwf.btn1.disabled = true
					objSwf.ling_1._visible = true
				end
			end
			if i == 2 then
				if myVMidRewardState then  --v(2-3)奖励未领取
					objSwf.btn2._visible = true
					objSwf.btn2.disabled = false
					objSwf.ling_2._visible = false
				else
					objSwf.btn2._visible = false
					objSwf.btn2.disabled = true
					objSwf.ling_2._visible = true
				end
			end
			if i == 3 then
				if myVThreeRewardState then  --v(4-5)奖励未领取
					objSwf.btn3._visible = true
					objSwf.btn3.disabled = false
					objSwf.ling_3._visible = false
				else
					objSwf.btn3._visible = false
					objSwf.btn3.disabled = true
					objSwf.ling_3._visible = true
				end
			end
		end
	else
		for i=1,3 do
			objSwf['btn'..i]._visible = true
			objSwf['btn'..i].disabled = false
			objSwf['ling_'..i]._visible = false
		end
	end
end

-- 称号信息
function UIVplanTitleNew:InitTitleData( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfgT1,cfgT2,cfgT3 = t_title[t_vtype[3].title],t_title[t_vtype[4].title],t_title[t_vtype[5].title]
	if not cfgT1 or not cfgT2 or not cfgT3 then return end
	local bigIcon1,bigIcon2,bigIcon3 = cfgT1.bigIcon,cfgT2.bigIcon,cfgT3.bigIcon
	if not bigIcon1 or not bigIcon2 or not bigIcon3 then return end
	local func = function ()
		objSwf.title1.source = ResUtil:GetTitleIconSwf(bigIcon1);
		objSwf.title2.source = ResUtil:GetTitleIconSwf(bigIcon2);
		objSwf.title3.source = ResUtil:GetTitleIconSwf(bigIcon3);
	end
	UILoaderManager:LoadList({ResUtil:GetTitleIconSwf(bigIcon1),ResUtil:GetTitleIconSwf(bigIcon2),ResUtil:GetTitleIconSwf(bigIcon3)},func);
	objSwf.title1.loaded = function() 
						   objSwf.title1.content._xscale = cfgT1.titleUIscale*100;
						   objSwf.title1.content._yscale = cfgT1.titleUIscale*100;
						   objSwf.title1.content._x = -toint(cfgT1.titleWidth * cfgT1.titleUIscale/2)+10
						   objSwf.title1.content._y = -toint(cfgT1.titleHeight * cfgT1.titleUIscale/2)
						   end
	objSwf.title2.loaded = function() 
						   objSwf.title2.content._xscale = cfgT2.titleUIscale*100;
						   objSwf.title2.content._yscale = cfgT2.titleUIscale*100;
						   objSwf.title2.content._x = -toint(cfgT2.titleWidth * cfgT2.titleUIscale/2)+10
						   objSwf.title2.content._y = -toint(cfgT2.titleHeight * cfgT2.titleUIscale/2)
						   end
	objSwf.title3.loaded = function() 
						   objSwf.title3.content._xscale = cfgT3.titleUIscale*100;
						   objSwf.title3.content._yscale = cfgT3.titleUIscale*100;
						   objSwf.title3.content._x = -toint(cfgT3.titleWidth * cfgT3.titleUIscale/2)+10
						   objSwf.title3.content._y = -toint(cfgT3.titleHeight * cfgT3.titleUIscale/2)
						   end
end

function UIVplanTitleNew:OnVOneClick( )
	local myVLevel = VplanModel:GetVPlanLevel()
	local myVOneRewardState   = VplanModel:GetLowTitle( )   
	if myVLevel >= 1 and myVOneRewardState then
		VplanController:ReqVplanTitle(1)
	elseif myVLevel >= 1 and myVOneRewardState == false then
		FloatManager:AddNormal(StrConfig["vplan508"])
	else
		FloatManager:AddNormal(StrConfig["vplan507"])
	end
end

function UIVplanTitleNew:OnVTwoClick( )
	local myVLevel = VplanModel:GetVPlanLevel()
	local myVMidRewardState   = VplanModel:GetMidTitle( )  
	if myVLevel >= 2 and myVMidRewardState then
		VplanController:ReqVplanTitle(2)
	elseif myVLevel >= 2 and myVMidRewardState == false then
		FloatManager:AddNormal(StrConfig["vplan508"])
	else
		FloatManager:AddNormal(StrConfig["vplan507"])
	end
end

function UIVplanTitleNew:OnVThreeClick( )
	local myVLevel = VplanModel:GetVPlanLevel()
	local myVThreeRewardState = VplanModel:GetHighTitle( ) 
	if myVLevel >= 4 and myVThreeRewardState then
		VplanController:ReqVplanTitle(3)
	elseif myVLevel >= 4 and myVThreeRewardState == false then
		FloatManager:AddNormal(StrConfig["vplan508"])
	else
		FloatManager:AddNormal(StrConfig["vplan507"]);
	end
end

function UIVplanTitleNew:HandleNotification(name,body)
	if name == NotifyConsts.VFlagChange then
		self:InitBtnShowData()
	end
end

function UIVplanTitleNew:ListNotificationInterests()
	return {
		NotifyConsts.VFlagChange,
	}
end