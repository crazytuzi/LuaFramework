--[[--
	初始化控件

	--By: yun.bo
	--2013/7/8
]]

require('TFFramework.client.system.components.TFUIBase')

require('TFFramework.client.system.components.TFWidget')
require('TFFramework.client.system.components.TFArmature')
require('TFFramework.client.system.components.TFAudio')
require('TFFramework.client.system.components.TFButton')
require('TFFramework.client.system.components.TFButtonGroup')
require('TFFramework.client.system.components.TFCheckBox')
require('TFFramework.client.system.components.TFCoverFlow')
require('TFFramework.client.system.components.TFDragPanel')
require('TFFramework.client.system.components.TFGroupButton')
require('TFFramework.client.system.components.TFImage')
require('TFFramework.client.system.components.TFLabelBMFont')
require('TFFramework.client.system.components.TFLabel')
require('TFFramework.client.system.components.TFLoadingBar')
require('TFFramework.client.system.components.TFLua')
require('TFFramework.client.system.components.TFMovieClip')
require('TFFramework.client.system.components.TFPanel')
require('TFFramework.client.system.components.TFScrollView')
require('TFFramework.client.system.components.TFTextArea')
require('TFFramework.client.system.components.TFTextButton')
require('TFFramework.client.system.components.TFTextField')
require('TFFramework.client.system.components.TFTableView')
require('TFFramework.client.system.components.TFTableViewCell')
require('TFFramework.client.system.components.TFPageView')
require('TFFramework.client.system.components.TFLoading')
require('TFFramework.client.system.components.TFListView')

require('TFFramework.client.system.components.TFSlider')
require('TFFramework.client.system.components.TFParticle')
require('TFFramework.client.system.components.TFRichText')

TFUIBase.registerComponents = {
	['TFTextButton']	 = TFTextButton,			
	['TFButton']		 = TFButton,		
	['TFButtonGroup']	 = TFButtonGroup,			
	['TFCheckBox']		 = TFCheckBox,		
	['TFDragPanel']		 = TFDragPanel,		
	['TFGroupButton']	 = TFGroupButton,			
	['TFImage']			 = TFImage,	
	['TFLabelBMFont']	 = TFLabelBMFont,			
	['TFLabel']			 = TFLabel,	
	['TFLoadingBar']	 = TFLoadingBar,			
	['TFLua']			 = TFLua,	
	['TFMovieClip']		 = TFMovieClip,		
	['TFPanel']			 = TFPanel,	
	['TFScrollView']	 = TFScrollView,			
	['TFTextArea']		 = TFTextArea,		
	['TFTextField']		 = TFTextField,		
	['TFTableView']		 = TFTableView,		
	['TFTableViewCell']	 = TFTableViewCell,			
	['TFCoverFlow']		 = TFCoverFlow,		
	['TFPageView']		 = TFPageView,		
	['TFArmature']		 = TFArmature,		
	['TFAudio']			 = TFAudio,	
	['TFLoading']		 = TFLoading,		
	['TFListView']		 = TFListView,		
	['TFSlider']		 = TFSlider,		
	['TFParticle']		 = TFParticle,		
	['TFRichText']		 = TFRichText,
}