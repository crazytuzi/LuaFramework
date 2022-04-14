--
-- @Author: LaoY
-- @Date:   2021-11-17 15:37:42
--


NftLoginPanel = NftLoginPanel or class("NftLoginPanel",BasePanel)

function NftLoginPanel:ctor()
	self.abName = "nft"
	self.assetName = "NftLoginPanel"
	self.layer = "UI"

	self.use_background = true

	self.m_IsConnect = false
end

function NftLoginPanel:dctor()

	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

end

function NftLoginPanel:Open( )
	NftLoginPanel.super.Open(self)
end

function NftLoginPanel:LoadCallBack()
	self.nodes = {
		"img_bg/img_icon_2",
		"img_bg/img_icon_1/btn_Connect/txt_Connect",
		"img_bg/img_icon_1/btn_Connect",
		"img_bg/img_icon_2/btn_Login/txt_Login",
		"img_bg/img_icon_2/btn_Login",
	}
	self:GetChildren(self.nodes)

	self.img_component = GetImage(self.img_icon_2)

	self.m_txt_Connect = GetText(self.txt_Connect)
	self.m_txt_Login = GetText(self.txt_Login)

	self:AddEvent()

	self:UpdateConnectState()
end

function NftLoginPanel:AddEvent()
    local function call_back()
    	if self.m_IsConnect then
    		return
    	end
    	NFTManager.Init()
        NFTManager.Connect()
    end
    AddButtonEvent(self.btn_Connect.gameObject, call_back)

    local function call_back()
    	NFTManager.SignAndLogin()
    end
    AddButtonEvent(self.btn_Login.gameObject, call_back)


    self.global_event_list = {}
    local function call_back(funcName,code,data)
    	if funcName == "Connect" then
    		self.m_IsConnect = true
    		self:UpdateConnectState()
    	elseif funcName == "SignAndLogin" then
    		if code == 0 then
    			self:Close()
    		end
    	end
    end
    self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(NFTManager.Events.Update, call_back)
end

function NftLoginPanel:UpdateConnectState()
	self:UpdateConnectTextState()
	self:UpdateIconState()
end

function NftLoginPanel:UpdateConnectTextState()
	local str = self.m_IsConnect and "已连接" or "连接钱包"
	self.m_txt_Connect.text = str
end

function NftLoginPanel:UpdateIconState()
	local abName = 'nft_image'
	local assetName = self.m_IsConnect and 'img_icon_state_1' or 'img_icon_state_2'
	if self.assetName == assetName then
		return
	end
	self.assetName = assetName
	lua_resMgr:SetImageTexture(self,self.img_component, abName, assetName,true)
end

function NftLoginPanel:OpenCallBack()
	self:UpdateView()
end

function NftLoginPanel:UpdateView( )

end

function NftLoginPanel:CloseCallBack()

end