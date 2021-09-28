KuanHuanActivityChongZhiRankData = KuanHuanActivityChongZhiRankData or BaseClass(BaseEvent)

function KuanHuanActivityChongZhiRankData:__init()
	if nil ~= KuanHuanActivityChongZhiRankData.Instance then
		return
	end

	KuanHuanActivityChongZhiRankData.Instance = self
end

function KuanHuanActivityChongZhiRankData:__delete()
	KuanHuanActivityChongZhiRankData.Instance = nil
end

--dealy