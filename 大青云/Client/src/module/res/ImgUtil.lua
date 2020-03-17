--[[
ImgUtil
lizhuangzhuang
2014年10月31日11:42:03
]]

_G.ImgUtil = {};

--灰态图片
ImgUtil.grayImages = {};
--红色图片
ImgUtil.redImages = {};

--获取灰态图片
--每次调用都会产生新的Image对象，谨慎使用
function ImgUtil:GetGrayImgUrl(url)
	if url:lead("img://") then
		url = url:sub(7);
	end
	local img = self.grayImages[url];
	if not img then
		img = _Image.new(url);
		img:processHSL(0,0,10);
		self.grayImages[url] = img;
	end
	return UIManager.stage:GetImageUrl(img);
end

--删除灰态图片
--垃圾回收
function ImgUtil:DeleteGrayImg(url)
	if url:lead("img://") then
		url = url:sub(7);
	end
	if self.grayImages[url] then
		self.grayImages[url] = nil;
	end
end

--获取红色滤镜
--每次调用都会产生新的Image对象，谨慎使用
function ImgUtil:GetRedImgUrl(url)
	if url:lead("img://") then
		url = url:sub(7);
	end
	local img = self.redImages[url];
	if not img then
		img = _Image.new(url);
		img:processHSL(0,50,0);
		self.redImages[url] = img;
	end
	return UIManager.stage:GetImageUrl(img);
end

--删除
function ImgUtil:DeleteRedImg(url)
	if url:lead("img://") then
		url = url:sub(7);
	end
	if self.redImages[url] then
		self.redImages[url] = nil;
	end
end

--初始化表情
function ImgUtil:InitFace()
	print("init face");
	self.faceImgs = {};
	for i,cfg in pairs(ChatConsts.Face) do
		local url = string.sub(cfg.url,17,#cfg.url-4);
		local img = _Image.new(url);
		table.push(self.faceImgs,img)
	end
	print("init face over")
end
