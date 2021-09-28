MarryNoticeData = MarryNoticeData or BaseClass()

function MarryNoticeData:__init()
    if MarryNoticeData.Instance then
        print_error("[MarryNoticeData] Attempt to create singleton twice!")
        return
    end
    MarryNoticeData.Instance = self

    local marriage_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto")
    self.marry_songhua_consume_glod = marriage_cfg.other[1].marry_songhua_consume_glod or 0
    self.blessing_list = {}
end

function MarryNoticeData:__delete()
	self.blessing_list = {}
    MarryNoticeData.Instance = nil
end

-- 送花价格
function MarryNoticeData:GetFlowerPrice()
	return self.marry_songhua_consume_glod
end

-- 增加祝贺
function MarryNoticeData:AddBlessing(info)
	table.insert(self.blessing_list, 1, info)
end

function MarryNoticeData:GetBlessing()
	return self.blessing_list
end