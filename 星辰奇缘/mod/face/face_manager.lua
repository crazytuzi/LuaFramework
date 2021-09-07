-- @author 黄耀聪
-- @date 2017年8月28日, 星期一

FaceManager = FaceManager or BaseClass(BaseManager)

function FaceManager:__init()
    if FaceManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    FaceManager.Instance = self

    self.model = FaceModel.New()

    self:InitHandler()

    self.OnBigFaceClick = EventLib.New()
    self.OnGetNewFace = EventLib.New()
    self.OnFreshTips = EventLib.New()
    self.OnGetShowFace = EventLib.New()
end

function FaceManager:__delete()
	self.OnBigFaceClick:DeleteMe()
    self.OnBigFaceClick = nil
    self.OnGetNewFace:DeleteMe()
    self.OnGetNewFace = nil
end

function FaceManager:InitHandler()
	self:AddNetHandler(10429, self.On10429)
	self:AddNetHandler(10430, self.On10430)
    self:AddNetHandler(10431, self.On10431)
end

function FaceManager:OpenWindow(args)
    self.model:OpenWindow(args)
end


function FaceManager:Send10429()
    self:Send(10430, {})
end

function FaceManager:On10429(data)
	BaseUtils.dump(data, "On10429")
	if data.num == 0 then
		self.OnGetNewFace:Fire(data.val)
	end
    self.OnGetShowFace:Fire(data)
end

function FaceManager:Send10430(id)
	-- print("Send10430")
	-- print(id)
	self.exchangeFaceId = id
    self:Send(10430, {id = id})
end

function FaceManager:On10430(data)
	-- BaseUtils.dump(data, "On10430")
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.flag == 1 then
		self.OnGetNewFace:Fire(self.exchangeFaceId)
        self.OnFreshTips:Fire()
	end
end

function FaceManager:Send10431(type)
    print("发送协议10431:" .. type)
    self:Send(10431, {type = type})
end

function FaceManager:On10431(data)
    BaseUtils.dump(data,"协议返回10431")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end