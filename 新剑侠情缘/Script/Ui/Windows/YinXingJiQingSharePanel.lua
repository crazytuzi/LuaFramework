local tbUi = Ui:CreateClass("YXJQ_SharePanel")

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnSave = function (self)
		self:TaskScreenShot("ScreenShot")
	end;
	BtnShare1 = function (self)
		self:TaskScreenShot("Share2Friend")
	end;
	BtnShare2 = function (self)
		self:TaskScreenShot("Share2Zone")
	end;
}

tbUi.tbContent = {
	{"大吉", "情定", "嫁娶 挖高宝", "缠绵织就鸳鸯帕"},
	{"大吉", "情定", "嫁娶 挖高宝", "此生托付鸳鸯帕"},
	{"大吉", "文定", "嫁娶 挖高宝", "交颈双雁翩翩回"},
	{"大吉", "白首", "嫁娶 挖高宝", "一双白头两相守"},
	{"中吉", "无猜", "拜师 结拜 捡徒弟", "竹马青梅长干里"},
	{"中吉", "守护", "拜师 结拜 捡徒弟", "身化千风护万安"},
	{"中吉", "相伴", "拜师 结拜 捡徒弟", "红袖添香两心知"},
	{"中吉", "相伴", "拜师 结拜 捡徒弟", "一生一世一双人"},
	{"小吉", "梦回", "植树 表白 送花草", "春堤寻觅红罗裳"},
	{"小吉", "相思", "植树 表白 送花草", "看罢丁香与豆蔻"},
	{"小吉", "相思", "植树 表白 送花草", "千里婵娟两地人"},
	{"小吉", "相思", "植树 表白 送花草", "红豆巧传千心结"},
	{"小吉", "重逢", "植树 表白 送花草", "金风玉露忘朝暮"},
	{"中", "别离", "鉴定 挚友重逢", "离人双泪明珠垂"},
	{"中", "别离", "鉴定 挚友重逢", "浪迹天涯别故人"},
	{"中", "难圆", "鉴定 挚友重逢", "此情不得两全法"},
	{"中", "难圆", "鉴定 挚友重逢", "宁负天下不负卿"},
	{"中", "缘尽", "鉴定 挚友重逢", "缺月寒枝人不回"},
	{"中", "缘尽", "鉴定 挚友重逢", "情深缘浅灯火寒"},
	{"中", "缘尽", "鉴定 挚友重逢", "苦恋成空化劫灰"},
}

function tbUi:OnOpen()
	self.nContentIdx = self.nContentIdx or MathRandom(#self.tbContent)
	for nIdx, szNode in ipairs({"Title1", "Title2", "Content1", "Content2"}) do
		self.pPanel:Label_SetText(szNode, self.tbContent[self.nContentIdx][nIdx])
	end
	self.pPanel:Label_SetText("Txt1", Sdk:IsLoginByQQ() and "分享给QQ好友" or "分享给微信好友")
	self.pPanel:Label_SetText("Txt2", Sdk:IsLoginByQQ() and "分享给QQ空间" or "分享到朋友圈")
end

function tbUi:TaskScreenShot(szFunc)
	self.pPanel:SetActive("Button", false)

	UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO)

	Timer:Register(3, function ()
		self[szFunc](self)
	end)

	Timer:Register(8, function ()
		self.pPanel:SetActive("Button", true)
	end)
end

function tbUi:ScreenShot()
	local szFileName = string.format("yinxingjiqing_%d.jpg", os.time())
	Ui.ToolFunction.SaveScreenShot(szFileName)
	Ui:AddCenterMsg("拍照成功！照片已保存至相册")
end

function tbUi:Share2Friend()
	Sdk:TlogShare("YinXingJiQing")

	local szType = Sdk:IsLoginByQQ() and "QQ" or "WX"
	Sdk:SharePhoto(szType)
end

function tbUi:Share2Zone()
	Sdk:TlogShare("YinXingJiQing")

	local szType = Sdk:IsLoginByQQ() and "QZone" or "WXMo"
	Sdk:SharePhoto(szType, nil, nil, nil, "YXJQ_SharePanel")
end