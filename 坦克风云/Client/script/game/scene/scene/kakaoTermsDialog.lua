--kakao用户协议的面板，显示在登录面板上，覆盖登录按钮，用户必须点同意才能继续游戏
kakaoTermsDialog=smallDialog:new()
function kakaoTermsDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=550
	self.dialogHeight=nil
	self.tagOffset=518
	self.strList1=
	{
		"[통합약관 