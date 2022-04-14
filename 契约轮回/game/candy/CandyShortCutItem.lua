-- @Author: lwj
-- @Date:   2019-03-05 11:40:46
-- @Last Modified time: 2019-03-05 11:40:48

CandyShortCutItem = CandyShortCutItem or class("CandyShortCutItem", BaseItem)
local CandyShortCutItem = CandyShortCutItem

function CandyShortCutItem:ctor(parent_node, layer)
    --CandyShortCutItem.super.Load(self)
    self.abName = "candy"
    self.assetName = "CandyShortCutItem"
    self.layer = layer

    CandyShortCutItem.super.Load(self)
    self.model = CandyModel.GetInstance()
end

function CandyShortCutItem:dctor()
    if self.lua_link_text then
        self.lua_link_text:destroy()
    end
end

function CandyShortCutItem:LoadCallBack()
    self.nodes = {
        "bg",
        "des",
    }
    self:GetChildren(self.nodes)
    self.des = GetLinkText(self.des)
    --self.des = self.des:GetComponent('InlineText')
    --self.des.inlineManager = self.model.inlineManagerScpButtom

    self:AddEvent()
    self:UpdateView()
    self.transform:SetSiblingIndex(self.data.index - 1)
end

function CandyShortCutItem:AddEvent()
    local function callback()
        local desc = self.data.des
        for w in string.gmatch(desc, "(<.->)") do
            local tmp = ""
            for w2 in string.gmatch(w, "emoji:(%d+)") do
                tmp=w2
            end
            local emoji_id = ChatModel:GetInstance():GetEmojiId(tmp)
            desc = string.gsub(desc, w, emoji_id)
        end
        GlobalEvent:Brocast(ChatEvent.ClickEmoji, desc)
    end
    AddClickEvent(self.bg.gameObject, callback)
end

function CandyShortCutItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function CandyShortCutItem:UpdateView()
    --lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_daily", self.data.conData.pic, true, nil, false)
    self.lua_link_text = LuaLinkImageText(self, self.des)
    self.lua_link_text:clear()
    self.des.text = self.data.des
end
