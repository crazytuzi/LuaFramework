-- 单项成就
-- ljh 20160718
VisitHomeMemberItem = VisitHomeMemberItem or BaseClass()

function VisitHomeMemberItem:__init(gameObject, parent)
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

    self.button = self.transform:FindChild("Button"):GetComponent(Button)
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnButtonClick(self.gameObject) end)
    self.buttontext = self.transform:FindChild("Button/Text"):GetComponent(Text)
    self.buttonimage = self.transform:FindChild("Button"):GetComponent(Image)
end

--设置
function VisitHomeMemberItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function VisitHomeMemberItem:Release()
end

function VisitHomeMemberItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function VisitHomeMemberItem:update_my_self(_data, _index)
	self.data = _data
	-- local data = _data
	-- self.gameObject.name = tostring(data.id)
    if self.data.type == "friend" then
    	-- self.bgobject:SetActive(_index % 2 == 0)
    	self.nametext.text = tostring(self.data.name)
    	self.headimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.data.classes, self.data.sex))
        if self.data.home_data ~= nil then
        	self.homeleveltext.text = DataFamily.data_home_data[self.data.home_data.lev].name2
        	self.homevnvaltext.text = tostring(self.data.home_data.env_val)
            local lock = (self.data.home_data.visit_lock == 3 or self.data.home_data.visit_lock == 5)
        	self.lockobject:SetActive(lock)
        	self.button.gameObject:SetActive(not lock)
            self.noHome:SetActive(false)
            self.buttontext.text = TI18N("拜访")
            self.buttonimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        else
            self.homeleveltext.text = TI18N("无家可归")
            self.homevnvaltext.text = "0"
            self.lockobject:SetActive(false)
            self.button.gameObject:SetActive(false)
            self.noHome:SetActive(true)
        end
    elseif self.data.type == "guild" then
        -- self.bgobject:SetActive(_index % 2 == 0)
        self.nametext.text = tostring(self.data.Name)
        self.headimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.data.Classes, self.data.Sex))
        self.homeleveltext.text = DataFamily.data_home_data[self.data.home_data.lev].name2
        self.homevnvaltext.text = tostring(self.data.home_data.env_val)
        local lock = (self.data.home_data.visit_lock == 2 or self.data.home_data.visit_lock == 5)
        self.lockobject:SetActive(lock)
        self.button.gameObject:SetActive(not lock)
        self.noHome:SetActive(false)

        if self.data.home_data.isSelf then
            self.buttontext.text = TI18N("回家")
            self.buttonimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            self.buttontext.text = TI18N("拜访")
            self.buttonimage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        end
    end
end

function VisitHomeMemberItem:Refresh(args)

end

function VisitHomeMemberItem:OnButtonClick()
    -- HomeManager.Instance.model:CloseVisitHomeWindow()
    self.parent:OnClickClose()
    HomeManager.Instance:EnterOtherHome(self.data.home_data.fid, self.data.home_data.platform, self.data.home_data.zone_id)
end