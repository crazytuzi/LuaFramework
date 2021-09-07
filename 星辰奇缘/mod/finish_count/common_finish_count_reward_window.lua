------------------
--通关结算系统统一逻辑
------------------
CommonFinishCountRewardWindow = CommonFinishCountRewardWindow or BaseClass(BaseWindow)
local GameObject = UnityEngine.GameObject

function CommonFinishCountRewardWindow:__init(model)
    self.model = model

    self.name = "CommonFinishCountRewardWindow"

    self.isHideMainUI = false

    self.resList = {
        {file = AssetConfig.finish_count_reward_win, type = AssetType.Main}
    }

    self.time = 0

    self.X_list = {201, 163, 126, 89, 55, 22}
end



function CommonFinishCountRewardWindow:__delete()
    for i,v in ipairs(self.slot_list) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slot_list = nil

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.val2TextExt ~= nil then
        self.val2TextExt:DeleteMe()
        self.val2TextExt = nil
    end
    self:ClearDepAsset()
end

function CommonFinishCountRewardWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.finish_count_reward_win))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.MainCon = self.transform:Find("MainCon")

    self.CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseBtn.onClick:AddListener(function () self.model:CloseRewardWin_Common()  end)

    self.ImgTitle = self.MainCon:FindChild("ImgTitle")
    self.TxtTitleTop = self.ImgTitle:FindChild("TxtTitle"):GetComponent(Text)

    self.MidCon = self.MainCon:FindChild("MidCon")
    -- self.TxtPass = self.MidCon:FindChild("TxtPass"):GetComponent(Text)
    self.TxtPassVal1 = self.MidCon:FindChild("TxtPassVal1"):GetComponent(Text)
    self.TxtPassVal = self.MidCon:FindChild("TxtPassVal"):GetComponent(Text)
    self.TxtPassVal2 = self.MidCon:FindChild("TxtPassVal2"):GetComponent(Text)
    self.TxtCon = self.MidCon:FindChild("TxtCon"):GetComponent(Text)

    self.TxtPassVal1.text = ""
    self.TxtPassVal.text = ""
    self.TxtPassVal2.text = ""

    self.TxtPassVal2.transform.pivot = Vector2(0, 1)
    self.TxtPassVal2.alignment = 0
    self.TxtPassVal.transform.pivot = Vector2(0, 1)
    self.TxtPassVal.alignment = 0
    self.TxtPassVal1.transform.pivot = Vector2(0, 1)
    self.TxtPassVal1.alignment = 0


    self.valTextExt = MsgItemExt.New(self.TxtPassVal, 447, 16, 30)
    self.val1TextExt = MsgItemExt.New(self.TxtPassVal1, 447, 16, 30)
    self.val2TextExt = MsgItemExt.New(self.TxtPassVal2, 447, 20, 30)


    self.ImgBg = self.MidCon:FindChild("ImgBg")
    self.TxtTitle = self.ImgBg:FindChild("TxtTitle"):GetComponent(Text)
    self.ImgConfirmBtn = self.MainCon:FindChild("ImgConfirmBtn"):GetComponent(Button)
    self.ImgConfirmBtnTxt = self.ImgConfirmBtn.transform:FindChild("Text"):GetComponent(Text)
    self.ImgConfirmBtn.onClick:AddListener(function () self:on_confirm_btn()  end)

    self.ImgShareBtn = self.MainCon:FindChild("ImgShareBtn"):GetComponent(Button)
    self.ImgShareBtnTxt = self.ImgShareBtn.transform:FindChild("Text"):GetComponent(Text)
    self.ImgShareBtn.onClick:AddListener(function () self:on_share_btn() end)

    self.ImgConfirmBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
    self.ImgShareBtn.gameObject:SetActive(false)

    self.ConSlot = self.MidCon:FindChild("MaskScroll/ConSlot")
    self.BaseSlot = self.MidCon:Find("MaskScroll/ConSlot/SlotConbase").gameObject

    self.slot_list = {}
    self.slot_con_list = {}
    -- for i=1,6 do
    --     local slot_con = self.ConSlot:FindChild(string.format("SlotCon%s", i))
    --     local slot = self:create_equip_slot(slot_con)
    --     table.insert(self.slot_list, slot)
    --     table.insert(self.slot_con_list, slot_con)
    -- end

    self:update_info()
end

--确定按钮点击事件
function CommonFinishCountRewardWindow:on_confirm_btn()
    self.model:CloseRewardWin_Common()
    if self.model.reward_win_data.confirm_callback ~= nil then
    	self.model.reward_win_data.confirm_callback()
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

--分享按钮点击事件
function CommonFinishCountRewardWindow:on_share_btn()
	self.model:CloseRewardWin_Common()
	if self.model.reward_win_data.share_callback ~= nil then
    	self.model.reward_win_data.share_callback()
    end
end

function CommonFinishCountRewardWindow:create_equip_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

function CommonFinishCountRewardWindow:set_stone_slot_data(slot, data)
    if data ~= nil then
        local cell = ItemData.New()
        cell:SetBase(data)
        slot:SetAll(cell, nil)
    else
        slot:SetAll(nil, nil)
    end
end

function CommonFinishCountRewardWindow:update_info()
	local data = self.model.reward_win_data

    self.ImgConfirmBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-100, -119)
    self.ImgConfirmBtnTxt.text = data.confirm_str

    if data.share_str == nil then
        self.ImgConfirmBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -119)
        self.ImgShareBtn.gameObject:SetActive(false)
    else
    	self.ImgShareBtnTxt.text = data.share_str
    	self.ImgShareBtn.gameObject:SetActive(true)
    end

    if data.confirm_str == nil then
        self.ImgShareBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -119)
        self.ImgConfirmBtn.gameObject:SetActive(false)
    end

    if data.titleTop ~= nil then self.TxtTitleTop.text = data.titleTop end

    -- self.TxtPass.text = data.pass
    -- if data.val ~= nil then self.TxtPassVal.text = data.val end
    if data.val ~= nil then self.valTextExt:SetData(data.val) end
    -- if data.val1 ~= nil then self.TxtPassVal1.text =  data.val1 end
    if data.val1 ~= nil then self.val1TextExt:SetData(data.val1) end
    if data.val2 ~= nil then self.val2TextExt:SetData(data.val2) end
    -- if data.val2 ~= nil then self.TxtPassVal2.text =  data.val2 end

    local size = self.valTextExt.contentTrans.sizeDelta
    local size1 = self.val1TextExt.contentTrans.sizeDelta
    local size2 = self.val2TextExt.contentTrans.sizeDelta

    local height = 0
    local pos_y = 0

    if data.val1 ~= nil and data.val1 ~= "" then
        height = height + size1.y
    end
    if data.val ~= nil and data.val ~= "" then
        height = height + size.y
    end
    if data.val2 ~= nil and data.val2 ~= "" then
        height = height + size2.y
    end

    if data.val2 ~= nil and data.val2 ~= "" then
        self.val2TextExt.contentTrans.anchoredPosition3D = Vector3(-size2.x / 2, 60 + height / 2, 0)
        pos_y = size2.y
    end
    if data.val1 ~= nil and data.val1 ~= "" then
        self.val1TextExt.contentTrans.anchoredPosition3D = Vector3(-size1.x / 2, 60 - pos_y + height / 2, 0)
        pos_y = pos_y + size1.y
    end
    if data.val ~= nil and data.val ~= "" then
        self.valTextExt.contentTrans.anchoredPosition3D = Vector3(-size.x / 2, 60 - pos_y + height / 2, 0)
    end

    if data.reward_title ~= nil then
        self.TxtTitle.text = data.reward_title
    end

    if self.timerId == nil then
        if data.sure_time ~= nil and data.sure_time > 0 then
            self.time = data.sure_time
            self.timerId = LuaTimer.Add(0, 1000, function() self:sureCountDown() end)
        end
    end
    self:InitSlot()
    local reward_list = data.reward_list
    if reward_list ~= nil then
        local len = #reward_list
        -- len = len > 6 and 6 or len
        if len == 0 then
            if data.noreward_text ~= nil then
                self.TxtCon.text = data.noreward_text
            end
            self.TxtCon.gameObject:SetActive(true)
            return
        end
	    for i=1,len do
	        local data = reward_list[i]
	        local base_data = DataItem.data_get[data.id]
	        self.slot_con_list[i].gameObject:SetActive(true)
	        self:set_stone_slot_data(self.slot_list[i], base_data)
	        self.slot_list[i]:SetNum(data.num)
	    end
	    -- self.ConSlot:GetComponent(RectTransform).anchoredPosition = Vector2(self.X_list[len], -135.6)
	end
end

function CommonFinishCountRewardWindow:sureCountDown()
    local data = self.model.reward_win_data
    if self.time > 0 then
        self.time = self.time - 1
        self.ImgConfirmBtnTxt.text = data.confirm_str.." ("..tostring(self.time)..")"
    else
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
        self:on_confirm_btn()
    end
end


function CommonFinishCountRewardWindow:InitSlot()
    local reward_llist = self.model.reward_win_data.reward_list
    for i=1,#reward_llist do
        local slot_con = GameObject.Instantiate(self.BaseSlot)
        slot_con.name = string.format("SlotCon%s", i)
        slot_con = slot_con.transform
        slot_con:SetParent(self.ConSlot)
        slot_con.localScale = Vector3.one
        local slot = self:create_equip_slot(slot_con)
        table.insert(self.slot_list, slot)
        table.insert(self.slot_con_list, slot_con)
    end
end