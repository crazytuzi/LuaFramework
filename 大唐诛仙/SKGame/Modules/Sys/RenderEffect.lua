--====================================================================================
--特效管理
--====================================================================================

RenderEffect =BaseClass{}


function RenderEffect:__init(mat)
	self.dissolve_shader_name_ = "SL_DiffuseCutOffDissolve"
	self.mat_ = mat
	self.tex_main_ = self.mat_.sharedMaterial.mainTexture  --将贴图引用保存，拷贝一份贴图出来，新的shader要用到
	self.shader_dissolve_ = Shader.Find(self.dissolve_shader_name_)
end
--死亡效果
function RenderEffect:DeadEffect()
	self:ChangeToDissolveShader(self.tex_main_,Color.New(1,132/255,0),0)
end


--转换shader
function RenderEffect:ChangeToDissolveShader(texDisslove,color,time)
	self.mat_.shader = self.shader_dissolve_
	self.mat_.SetTexture("_MainTex", texDisslove);
	self.mat_.SetTexture("_DissolveTex", texDisslove);
	self.mat_.SetColor("_Color", color);
	self.mat_.SetFloat("_DissolveUseTime", time);
	self.mat_.SetFloat("_Cutoff", 0.1);		
end

--设置消亡值
function RenderEffect:SetDissolveValue(value)
	if self.mat_ then
		self.mat_.SetFloat("_DissolveUseTime",value)
	end
end

function RenderEffect:__delete()

end

function RenderEffect:Stop()

end