--
-- @Author: chk
-- @Date:   2018-09-30 11:53:28
--
GoodsJumpItemItemSettor = GoodsJumpItemItemSettor or class("GoodsJumpItemItemSettor", BaseWidget)
local GoodsJumpItemItemSettor = GoodsJumpItemItemSettor

function GoodsJumpItemItemSettor:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "GoodsJumpItemItem"
    self.layer = layer

    -- self.model = 2222222222222end:GetInstance()
    GoodsJumpItemItemSettor.super.Load(self)
end

function GoodsJumpItemItemSettor:dctor()
end

function GoodsJumpItemItemSettor:LoadCallBack()
    self.nodes = {
        "Image",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    if self.need_loaded_end then
        self:ShowJumpInfo(self.jumpKey)
    end
end

function GoodsJumpItemItemSettor:AddEvent()
end

function GoodsJumpItemItemSettor:SetData(data)

end

function GoodsJumpItemItemSettor:ShowJumpInfo(jump_tbl, icon)
    if self.is_loaded then
        --local jpTbl = string.split(jumpKey, "@")
        if icon then
            lua_resMgr:SetImageTexture(self, self.Image:GetComponent('Image'), "main_image", icon, true)
        else
            local abName, assetName = GetLinkAbAssetName(jump_tbl[1], jump_tbl[2])
            if abName ~= nil and assetName ~= nil then
                lua_resMgr:SetImageTexture(self, self.Image:GetComponent('Image'), abName, assetName, true)
            end
        end

        local function call_back()
            --UnpackLinkConfig(jpTbl[1] .. "@" .. jpTbl[2] .. '@' .. jpTbl[3] .. '@' .. jpTbl[4])
            OpenLink(unpack(jump_tbl))
        end

        AddClickEvent(self.Image.gameObject, call_back)

        self.need_loaded_end = false
    else
        self.jumpKey = jump_tbl
        self.need_loaded_end = true
    end
end


