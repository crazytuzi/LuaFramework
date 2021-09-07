FairyLandLetterWindow = FairyLandLetterWindow or BaseClass(BaseWindow)
-------------------------
--幻境宝箱
-------------------------
function FairyLandLetterWindow:__init(model)
    self.model = model
    self.name = "FairyLandLetterWindow"
    self.windowId = WindowConfig.WinID.fairy_land_letter
    self.isHideMainUI = false
    self.resList = {
        {file = AssetConfig.fairy_land_letter_win, type = AssetType.Main}
    }

end

function FairyLandLetterWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FairyLandLetterWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fairy_land_letter_win))
    self.gameObject.name = "FairyLandLetterWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.TxtDesc1 = self.MainCon.transform:FindChild("TxtDesc1"):GetComponent(Text)

    self.BtnShare = self.MainCon.transform:FindChild("BtnShare"):GetComponent(Button)

    self.BtnShare.onClick:AddListener(function() self:on_click_share() end)
    self:update_info()
end

--点击分享按钮
function FairyLandLetterWindow:on_click_share()
    local str_1 = nil
    local temp_list = {}
    for i=1,#self.model.cur_fairy_data.forward_envoys do
        local da = self.model.cur_fairy_data.forward_envoys[i]
        temp_list[da.floor] = da
    end

    for i=1,11 do
        local d = temp_list[i]
        if d ~= nil then
            --有记录
            local name = ""
            if i == 1 or i ==5 or i == 9 then
                name = string.format("%s%s%s", i, TI18N("层"), self.model.type_names[d.unit_base])
            else
                name = string.format("%s%s%s", i, TI18N("层"), self.model.type_names[d.unit_base])
            end

            if str_1 ~= nil then
                str_1 = string.format("%s、%s", str_1 , name)
            else
                str_1 = name
            end
        else
            if str_1 ~= nil then
                if i == 1 or i ==5 or i == 9 then
                    str_1 = string.format("%s、%s%s%s", str_1 , i, TI18N("层"),TI18N("无"))
                else
                    str_1 = string.format("%s、%s%s%s", str_1 , i, TI18N("层"),TI18N("无"))
                end
            else
                str_1 = string.format("%s%s%s", i , TI18N("层"),TI18N("无"))
            end
        end
    end


    local chat_msg = string.format("%s%s", TI18N("彩虹冒险使者：") , str_1)
    -- chat_msg = "·1层绿、2层红、3层蓝、4层绿、·5层绿、6层无、7层无、8层绿、·9层绿、10层无、11层无"
    ChatManager.Instance:SendMsg(MsgEumn.ChatChannel.Guild, chat_msg, true)
end

--更新界面
function FairyLandLetterWindow:update_info()
    local str_1 = nil

    self.TxtDesc1.text = TI18N("无")

    local temp_list = {}
    for i=1,#self.model.cur_fairy_data.forward_envoys do
        local da = self.model.cur_fairy_data.forward_envoys[i]
        temp_list[da.floor] = da
    end

    for i=1,11 do
        local d = temp_list[i]
        if d ~= nil then
            --有记录
            local name = ""
            if i == 1 or i ==5 or i == 9 then
                name = string.format("%s%s<color='%s'>%s</color>", i, TI18N("层"),self.model.type_name_colors[d.unit_base], self.model.type_names[d.unit_base])
            else
                name = string.format("%s%s<color='%s'>%s</color>", i, TI18N("层"),self.model.type_name_colors[d.unit_base], self.model.type_names[d.unit_base])
            end

            if str_1 ~= nil then
                if i == 1 or i ==5 or i == 9 then
                    str_1 = string.format("%s、\n%s", str_1 , name)
                else
                    str_1 = string.format("%s、%s", str_1 , name)
                end
            else
                str_1 = name
            end
        else
            if str_1 ~= nil then
                if i == 1 or i ==5 or i == 9 then
                    str_1 = string.format("%s、\n%s%s%s", str_1 , i, TI18N("层"),TI18N("无"))
                else
                    str_1 = string.format("%s、%s%s%s", str_1 , i, TI18N("层"),TI18N("无"))
                end
            else
                str_1 = string.format("%s%s%s", i , TI18N("层"),TI18N("无"))
            end
        end
    end

    self.TxtDesc1.text = str_1
end