-- 豌豆邀请单条内容
-- 20160810
-- hzf
MagicBeanInviteItem = MagicBeanInviteItem or BaseClass()

function MagicBeanInviteItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.model = self.parent.model

    self.transform = self.gameObject.transform

    self.bgobject = self.transform:FindChild("Bg").gameObject
    self.nametext = self.transform:FindChild("Character/Name"):GetComponent(Text)
    self.headimage = self.transform:FindChild("Character/Icon/Image"):GetComponent(Image)
    self.homeleveltext = self.transform:FindChild("HomeLevel"):GetComponent(Text)
    self.homevnvaltext = self.transform:FindChild("HomEvnVal"):GetComponent(Text)
    self.lockobject = self.transform:FindChild("Lock").gameObject
    self.noHome = self.transform:FindChild("I18N_NoHome").gameObject
    self.noHomeText = self.transform:FindChild("I18N_NoHome"):GetComponent(Text)

    self.button = self.transform:FindChild("Button"):GetComponent(Button)
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnButtonClick(self.gameObject) end)
    self.buttontext = self.transform:FindChild("Button/Text"):GetComponent(Text)
    self.buttonimage = self.transform:FindChild("Button"):GetComponent(Image)
end

--设置
function MagicBeanInviteItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function MagicBeanInviteItem:Release()
end

function MagicBeanInviteItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function MagicBeanInviteItem:update_my_self(_data, _index)
    self.data = _data
    -- local data = _data
    -- self.gameObject.name = tostring(data.id)
    if self.data.type == "friend" then
        -- self.bgobject:SetActive(_index % 2 == 0)
        self.bgobject:SetActive(false)
        self.nametext.text = tostring(self.data.name)
        self.headimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.data.classes, self.data.sex))
        if self.data.home_data ~= nil then
            self.homeleveltext.text = DataFamily.data_home_data[self.data.home_data.lev].name2
            if self.parent.sorttype == 1 then
                self.homevnvaltext.text = tostring(self.data.times)
            else
                self.homevnvaltext.text = tostring(self.data.intimacy)
            end
            -- local lock = (self.data.home_data.visit_lock == 3 or self.data.home_data.visit_lock == 5)
            self.lockobject:SetActive(false)
            -- self.button.gameObject:SetActive(not lock)
            self.buttontext.text = TI18N("赠 送")
            self.buttonimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            if self.data.gived then
                self.noHomeText.text = TI18N("<color='#00ff00'>已赠</color>")
                self.noHome:SetActive(true)
                self.button.gameObject:SetActive(false)
            else
                self.noHome:SetActive(false)
                self.button.gameObject:SetActive(true)
            end
        else
            self.noHomeText.text = TI18N("暂无家园")
            self.homeleveltext.text = TI18N("无家可归")
            if self.parent.sorttype == 1 then
                self.homevnvaltext.text = tostring(self.data.times)
            else
                self.homevnvaltext.text = tostring(self.data.intimacy)
            end
            self.lockobject:SetActive(false)
            self.button.gameObject:SetActive(false)
            self.noHome:SetActive(true)
        end
    elseif self.data.type == "guild" then
        -- self.bgobject:SetActive(_index % 2 == 0)
        self.bgobject:SetActive(false)
        self.nametext.text = tostring(self.data.Name)
        self.headimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.data.Classes, self.data.Sex))
        self.homeleveltext.text = DataFamily.data_home_data[self.data.home_data.lev].name2
        self.homevnvaltext.text = tostring(self.data.times)
        -- local lock = (self.data.home_data.visit_lock == 2 or self.data.home_data.visit_lock == 5)
        self.lockobject:SetActive(false)
        -- self.button.gameObject:SetActive(not lock)
        -- self.noHome:SetActive(false)
        if self.data.home_data.isSelf then
            self.buttontext.text = TI18N("回家")
            self.buttonimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            if self.data.gived == true then
                self.noHomeText.text = TI18N("<color='#00ff00'>已赠</color>")
                self.noHome:SetActive(true)
                self.button.gameObject:SetActive(false)
            else
                self.buttontext.text = TI18N("赠 送")
                self.buttonimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.noHome:SetActive(false)
                self.button.gameObject:SetActive(true)
            end
        end
        if self.data.gived then
            self.noHomeText.text = TI18N("<color='#00ff00'>已赠</color>")
            self.noHome:SetActive(true)
            self.button.gameObject:SetActive(false)
        else
            self.noHome:SetActive(false)
            self.button.gameObject:SetActive(true)
        end
    end
end

function MagicBeanInviteItem:Refresh(args)

end

function MagicBeanInviteItem:OnButtonClick()
    -- HomeManager.Instance.model:CloseVisitHomeWindow()
    -- self.parent:OnClickClose()
    local temp = {{rid = self.data.home_data.fid, platform = self.data.home_data.platform, zone_id = self.data.home_data.zone_id}}
    if self.data.type == "friend" then
        temp = {{rid = self.data.id, platform = self.data.platform, zone_id = self.data.zone_id}}
    else
        temp = {{rid = self.data.Rid, platform = self.data.PlatForm, zone_id = self.data.ZoneId}}
    end
    HomeManager.Instance:Send11228(temp)
    -- HomeManager.Instance:EnterOtherHome(self.data.home_data.fid, self.data.home_data.platform, self.data.home_data.zone_id)
end
