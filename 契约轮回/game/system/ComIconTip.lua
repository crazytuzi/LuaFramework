--带icon的通用tip
ComIconTip = ComIconTip or class("ComIconTip", WindowPanel)
local this = ComIconTip

function ComIconTip:ctor(parent_node)
    self.abName = "system";
    self.assetName = "ComIconTip"
    self.layer = "UI"

    self.panel_type = 4;

    self.item = nil
end

function ComIconTip:dctor()
   
    if self.item then
        self.item:destroy()
        self.item = nil
    end

end

function ComIconTip:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function ComIconTip:LoadCallBack()
    self.nodes = {
        "message2","message1", "icon1","icon2", "sure","cancel","name",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0)

    self:InitUI()

    self:AddEvent()

    self:SetTileTextImage("system_image", "comicontip_title")
    
    self:UpdateView()
end

function ComIconTip:InitUI()
    self.message1 = GetText(self.message1)
    self.message2 = GetText(self.message2)
    self.name = GetText(self.name)
end

function ComIconTip:AddEvent()
    function ok_func(  )
        if self.data.ok_func then
            self.data.ok_func()
        end
        self:Close()
    end
    AddClickEvent(self.sure.gameObject,ok_func)
    AddClickEvent(self.cancel.gameObject,handler(self, self.Close))
end

function ComIconTip:UpdateView()
   
    self.message1.text = self.data.message1
    SetVisible(self.message1,self.data.message1 ~= nil)

    --设置字号
    self.data.msg1_font_size = self.data.msg1_font_size or self.message1.fontSize
    self.message1.fontSize = self.data.msg1_font_size

    self.message2.text = self.data.message2
    SetVisible(self.message2,self.data.message2 ~= nil)

    self.name.text = self.data.name
    SetVisible(self.name,self.data.name ~= nil)


    local icon = self.icon1
    if self.data.tip_type == 2 then

        --type2需要额外显示物品名

        icon = self.icon2
        --设置name文本颜色
        local colorNum = Config.db_item[self.data.param["item_id"]].color
        local color = ColorUtil.GetColor(colorNum)
        self.name.text =  string.format("<color=#%s>%s</color>",color,self.name.text)

        --往上移动message1
        SetLocalPositionZ(self.message1.transform,0)
        SetAnchoredPosition(self.message1.transform,4,74)
    end

    self.item = GoodsIconSettorTwo(icon)
    self.item:SetIcon(self.data.param)
end


