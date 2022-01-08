--[[
******铁匠铺宝石合成左侧栏*******

	-- by david.dai
	-- 2014/06/27
]]

local GemMergePanel = class("GemMergePanel", BaseLayer)

function GemMergePanel:ctor(gmId)
    self.super.ctor(self,gmId)
    self.gmId = gmId
    self:init("lua.uiconfig_mango_new.smithy.GemMergePanel")
end

function GemMergePanel:initUI(ui)
	self.super.initUI(self,ui)

    self.img_gem_arrow = TFDirector:getChildByPath(ui, 'img_gem_arrow')
    self.txt_gem_target = TFDirector:getChildByPath(ui, 'txt_gem_target')
    self.txt_target_name = TFDirector:getChildByPath(ui, 'txt_target_name')

    --装备图标信息区
	self.gem_table = {}
    for i = 1,EquipmentManager.kGemMergeSrcNum do
        local str = "img_base_gem" .. i
        self.gem_table[i] = TFDirector:getChildByPath(ui, str)
    end

    self.gem_table[EquipmentManager.kGemMergeTargetIndex] = TFDirector:getChildByPath(ui, "img_target_gem")
    self.txt_target_name    = TFDirector:getChildByPath(ui, "txt_target_name")
    self.txt_gem_attr       = TFDirector:getChildByPath(ui, "txt_gem_attr")

end

function GemMergePanel:removeUI()
    self.super.removeUI(self)
end

--[[
获取合成特效显示位置
]]
function GemMergePanel:getMergeEffectPosition()
    local _parent = self.img_gem_arrow:getParent()
    local pos = _parent:convertToWorldSpaceAR(self.img_gem_arrow:getPosition())
    --print("merge pos : ",pos)
    --pos.x = pos.x + 310
    --pos.y = pos.y + 50
    return pos
end

function GemMergePanel:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function GemMergePanel:setLogic( layer )
    self.logic = layer
end

function GemMergePanel:setGemIconVisiable(visiable)
    for i = 1,#self.gem_table do
        self.gem_table[i]:setVisible(visiable)
    end
    self.txt_target_name:setVisible(visiable)
    self.txt_gem_attr:setVisible(visiable)
end

function GemMergePanel:setGmId(gmId)
    self.gmId   = gmId
    self:refreshUI()
end

function GemMergePanel:dispose()
    self.super.dispose(self)
end
    
--刷新显示方法
function GemMergePanel:refreshUI()
    local srcGem = GemData:objectByID(self.gmId)
    if srcGem then
        self:setGemIconVisiable(true)
    else
        self:setGemIconVisiable(false)
        return
    end

    local srcGoods = ItemData:objectByID(self.gmId)
    local holdGoods = BagManager:getItemById(self.gmId)

    if holdGoods== nil then
        for i = 1,EquipmentManager.kGemMergeSrcNum do
            self.gem_table[i]:setVisible(false)
        end
    else
        for i = 1,EquipmentManager.kGemMergeSrcNum do
            --self.gem_table[i]:setVisible(true)
            self.gem_table[i]:setTexture(srcGoods:GetPath())
        end
        if holdGoods.num < 4 then
            for i = holdGoods.num + 1,EquipmentManager.kGemMergeSrcNum do
                self.gem_table[i]:setVisible(false)
            end
        end
    end

    local target = ItemData:objectByID(srcGem.merge_to)
    if target == nil then
        print("无法找到该宝石的数据  id" == srcGem.merge_to)
        return
    end
    local targetGoods = ItemData:objectByID(target.id)

    local targetAttr = GemData:objectByID(target.id)
    if targetAttr == nil  then
        return
    end

    self.txt_gem_target:setVisible(true)
    self.txt_gem_attr:setVisible(true)
    self.gem_table[5]:setVisible(true)
    local attr_index,attr_num = targetAttr:getAttribute()
    self.txt_target_name:setText(targetGoods.name)
    self.txt_gem_attr:setText(AttributeTypeStr[attr_index].."+"..attr_num)
    self.gem_table[5]:setTexture(targetGoods:GetPath())
end

function GemMergePanel:registerEvents()
	self.super.registerEvents(self)
end

function GemMergePanel:removeEvents()
    self.super.removeEvents(self)
end

return GemMergePanel
