KuanHuanActivityChongZhiRankCtrl = KuanHuanActivityChongZhiRankCtrl or BaseClass(BaseController)

function KuanHuanActivityChongZhiRankCtrl:__init()
	if nil ~= KuanHuanActivityChongZhiRankCtrl.Instance then
		return
	end

	KuanHuanActivityChongZhiRankCtrl.Instance = self

	self:RegisterAllProtocols()
end

function KuanHuanActivityChongZhiRankCtrl:__delete()
	KuanHuanActivityChongZhiRankCtrl.Instance = nil
end

function KuanHuanActivityChongZhiRankCtrl:RegisterAllProtocols()

end