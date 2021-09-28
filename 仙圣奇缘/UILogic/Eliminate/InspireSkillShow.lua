 --------------------------------------------------------------------------------------
-- 文件名: InspireSkillShow.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    不同的技能 替换 删除 更新的顺序不一样在装饰一下 
-- 描  述:    
-- 应  用:  
---------------------------------------------------------------------------------------
---交换 删除 添加 更新
SkillShowBase = class("SkillShowBase")
SkillShowBase.__index = SkillShowBase


function SkillShowBase:ctor()
	self.InspireShow = nil
	self.wgt = nil
	self.form = nil
end


function SkillShowBase:InitWgt(tbWgt, form)
	self.wgt = tbWgt
	self.form = form
end

function SkillShowBase:ShowNode()
	if self.wgt == nil or self.form == nil then return false end
	cclog("============SkillShowBase:ShowNode===================")

	self.InspireShow = InspireExchange.new()
	self.InspireShow:InitWgt(self.wgt, self.form)

	local showdel = InspireDelete.new()
	self.InspireShow:SetNextShow(showdel)

	local showAdd = InspireAddNew.new()
	showdel:SetNextShow(showAdd)

	self.InspireShow:ShowAction()

	return true
end




--更新 删除 添加
SkillShowDel = class("SkillShowDel", function () return SkillShowBase:new() end)
SkillShowDel.__index = SkillShowDel


function SkillShowDel:InitWgt(tbWgt, form)
	SkillShowBase:InitWgt(tbWgt, form)
end

function SkillShowDel:ShowNode()
	if self.wgt == nil or self.form == nil then return false end
cclog("============SkillShowDel:ShowNode===================")
	self.InspireShow = InspireRefresh.new()
	self.InspireShow:InitWgt(self.wgt, self.form)

	local showdel = InspireDelete.new()
	self.InspireShow:SetNextShow(showdel)

	local showAdd = InspireAddNew.new()
	showdel:SetNextShow(showAdd)

	self.InspireShow:ShowAction()

	return true
end



--只是做更新
SkillShowUpdate = class("SkillShowUpdate", function () return SkillShowBase:new() end)
SkillShowUpdate.__index = SkillShowUpdate


function SkillShowUpdate:InitWgt(tbWgt, form)
	SkillShowBase:InitWgt(tbWgt, form)
end

function SkillShowUpdate:ShowNode()
	if self.wgt == nil or self.form == nil then return false end
cclog("============SkillShowUpdate:ShowNode===================")
	self.InspireShow = InspireRefresh.new()
	self.InspireShow:InitWgt(self.wgt, self.form)

	self.InspireShow:ShowAction()

	return true
end


----删除跟添加
SkillShowDelandAnd = class("SkillShowDelandAnd", function () return SkillShowBase:new() end)
SkillShowDelandAnd.__index = SkillShowDelandAnd


function SkillShowDelandAnd:InitWgt(tbWgt, form)
	SkillShowBase:InitWgt(tbWgt, form)
end

function SkillShowDelandAnd:ShowNode()
	if self.wgt == nil or self.form == nil then return false end
cclog("============SkillShowDelandAnd:ShowNode===================")
	self.InspireShow = InspireDelete.new()
	self.InspireShow:InitWgt(self.wgt, self.form)

	local showAdd = InspireAddNew.new()
	self.InspireShow:SetNextShow(showAdd)

	self.InspireShow:ShowAction()

	return true
end