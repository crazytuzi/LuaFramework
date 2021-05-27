MovieGuideData = MovieGuideData or BaseClass(BaseController)

function MovieGuideData:__init()
	if MovieGuideData.Instance ~= nil then
		ErrorLog("[MovieGuideData] attempt to create singleton twice!")
		return
	end
	MovieGuideData.Instance = self
end	

function MovieGuideData:__delete()
end	

function MovieGuideData:GetGuideById(guide_id)
	return MovieGuide[guide_id]
end	