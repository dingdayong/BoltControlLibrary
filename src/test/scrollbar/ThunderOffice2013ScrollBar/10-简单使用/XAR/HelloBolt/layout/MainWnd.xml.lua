function OnClose(self)	----os.exit 效果等同于windows的exit函数，不推荐实际应用中直接使用	os.exit()endfunction OnMainWndSize(self, type_, width, height)	local objectTree = self:GetBindUIObjectTree()	local rootObject = objectTree:GetRootObject()		rootObject:SetObjPos(0, 0, width, height)endfunction OnProgressInitControl(self)		timer = XLGetObject("Xunlei.UIEngine.TimerManager")	timer:SetTimer(function (x)		local newProgress = self:GetProgress()		if newProgress >= 100 then			newProgress = 0		else			newProgress = newProgress + 1		end		self:SetProgress(newProgress)	end,100,true)end