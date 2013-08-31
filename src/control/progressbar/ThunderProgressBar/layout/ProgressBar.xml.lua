function SetAlpha(self,nAlpha)
	local obj = self:GetControlObject("ProgressText")
	obj:SetAlpha(nAlpha)
	local obj = self:GetControlObject("LightBkg.Ani.Light")
	obj:SetAlpha(nAlpha)
	local obj = self:GetControlObject("FullBkn")
	obj:SetAlpha(nAlpha)
	local obj = self:GetControlObject("EmptyBkn")
	obj:SetAlpha(nAlpha)
end

function CalcProgressText(self)
	local attr = self:GetAttribute()
	local text = self:GetControlObject("ProgressText")
	local progresstext 
	if attr.HighBound ~= attr.LowBound then
		--根据文字样式 计算对应的数据
		if attr.ShowTextStyle == 0 then
			local 	per = 0
			per = attr.Progress * 100 / (attr.HighBound - attr.LowBound)	
			-- progresstext = string.format("%.1f%%", per)
			local fr = 0.5 * math.pow(0.1, attr.Floor)
			local formatStr = "%." .. attr.Floor .. "f%%"
			if per > fr then
				progresstext = string.format(formatStr, per - fr)
			else
				progresstext = string.format(formatStr, 0)
			end
		elseif attr.ShowTextStyle == 1 then
			progresstext = string.format("%d/%d", attr.Progress, attr.HighBound - attr.LowBound)
		else
			error("need extended")
		end
	end
    return progresstext
end

function UpdateProgress(self)
    local attr = self:GetAttribute()
    local left,top,right,bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    
    local nFullWidth = width * attr.Progress / (attr.HighBound - attr.LowBound);
    local fullpart = self:GetControlObject("FullPart")
    fullpart:SetObjPos(0, 0, nFullWidth, height);
    
    local emptypart = self:GetControlObject("EmptyPart")
    emptypart:SetObjPos(nFullWidth, 0, width, height)
    
    local fullbkn = self:GetControlObject("FullBkn")
    fullbkn:SetObjPos(0, 0, width, height)
                
    local emptybkn = self:GetControlObject("EmptyBkn")
    emptybkn:SetObjPos(-nFullWidth, 0, width - nFullWidth, height)
    
    --local textpart = self:GetControlObject("TextPart")
    --textpart:SetObjPos(0, 0, width, height)
    local text = self:GetControlObject("ProgressText")
    local progresstext = self:CalcProgressText()
	if attr.ShowText then
		text:SetText(progresstext)
	end
    local textwidth, textheight = text:GetTextExtent()
    --text:SetObjPos((width - textwidth) / 2, 0, (width + textwidth) / 2, height)
    if nFullWidth >= (width + textwidth) / 2 then
        text:SetTextColorResID("system.white")
    else
        text:SetTextColorResID("system.black")
    end
end

function SetProgress(self, newProgress,inAnimation)
    local attr = self:GetAttribute()
	if not attr then
        return
    end
	if not inAnimation then
		if attr.nowAni then
			attr.nowAni:ForceStop()
			attr.nowAni = nil
		end
	end
	
    if attr.Progress == newProgress then
        return
    end
    
    if newProgress < attr.LowBound then
        newProgress = attr.LowBound
    elseif newProgress > attr.HighBound then
        newProgress = attr.HighBound
    end
    
    local oldProgress = attr.Progress
    attr.Progress = newProgress
    self:UpdateProgress()
end

function GetProgress(self)
    local attr = self:GetAttribute()
    return attr.Progress
end

function SetBound(self, newLowBound, newHighBound)
    local attr = self:GetAttribute()
    if (newLowBound or attr.LowBound) > (newHighBound or attr.HighBound) then
        return
    end
    attr.LowBound = newLowBound or attr.LowBound
    attr.HighBound = newHighBound or attr.HighBound
end

function GetBound(self)
    local attr = self:GetAttribute()
    return attr.LowBound, attr.HighBound
end

function SetStep(self, newStep)
    local attr = self:GetAttribute()
    local NewStep = newStep or attr.StepNum
    if NewStep < 0 then
        return
    end
    attr.StepNum = NewStep
end

function GetStep(self)
    local attr = self:GetAttribute()
    return attr.StepNum
end

function Step(self)
    local attr = self:GetAttribute()
    self:SetProgress(attr.Progress + attr.StepNum)
end


function OnBind(self)
    local attr = self:GetAttribute()
	
	local full = self:GetControlObject("FullBkn")
	local empty = self:GetControlObject("EmptyBkn")
	
	OnEnableChange(self, self:GetEnable())

    local text = self:GetControlObject("ProgressText")
    if attr.ShowText then
        text:SetVisible(true)
    else
        text:SetVisible(false)
		
    end
	
	if attr.Font then
		text:SetTextFontResID(attr.Font)
	end
    
    self:UpdateProgress()
	
	OnVisibleChange(self, self:GetVisible())
end

function OnPosChange(self)
    self:UpdateProgress()
end


function SetEmptyID(self,emptyID)
	local attr = self:GetAttribute()
	attr.EmptyID = emptyID
	
	local empty = self:GetControlObject("EmptyBkn")
	empty:SetTextureID(attr.EmptyID)
end

function GetEmptyID(self)
    local attr = self:GetAttribute()
	return attr.EmptyID
end

function SetFullID(self,fullID)
     local attr = self:GetAttribute()
	attr.FullID = fullID
	
	local full = self:GetControlObject("FullBkn")
	full:SetTextureID(attr.FullID)
end

function GetFullID(self)
    local attr = self:GetAttribute()
	return attr.FullID
end

function SetDisableEmptyID(self,disableEmptyID)
    local attr = self:GetAttribute()
	attr.DisableEmptyID = disableEmptyID
end

function GetDisableEmptyID(self)
    local attr = self:GetAttribute()
	return attr.DisableEmptyID
end

function SetDisableFullID(self,disableFullID)
    local attr = self:GetAttribute()
	attr.DisableFullID = disableFullID
end

function GetDisableFullID(self)
    local attr = self:GetAttribute()
	return attr.DisableFullID
end




function ProgressBar_GoAhead_OnAniStart(self)
	local attr = self:GetAttribute()
	local progAttr = attr.progress:GetAttribute()
	progAttr.nowAni = self
end

function ProgressBar_GoAhead_OnAniFinish(self)
	local attr = self:GetAttribute()
	local progAttr = attr.progress:GetAttribute()
	if progAttr then 
		if progAttr.nowAni then
			progAttr.nowAni = nil
		end
	end
end

	
	
function ProgressBar_GoAhead_OnEvent(self,old,new)
	if new == 4 then
		ProgressBar_GoAhead_OnAniFinish(self)
	end
	if new == 1 then
		ProgressBar_GoAhead_OnAniStart(self)
	end
end

function ProgressBar_GoAhead_Action(self)
	local attr = self:GetAttribute()
	local curve = self:GetCurve()
	local currenttime = self:GetRuningTime()
	local totaltime = self:GetTotalTime()
	local pstart = attr.pstart
	local pend = attr.pend
	local thisProgress = pstart + (pend - pstart) * curve:GetProgress(currenttime / totaltime)
	attr.progress:SetProgress(thisProgress,true)
end

function ProgressBar_GoAhead_Bind(self,obj,pend,pstart)
	local attr = self:GetAttribute()
	attr.progress = obj
	if not pstart then
		attr.pstart = obj:GetProgress()
	else
		attr.pstart = pstart
	end
	attr.pend = pend
	self:AttachListener(true,ProgressBar_GoAhead_OnEvent)
end

function Progress_OnInitControl(self)
	local light = self:GetControlObject("LightBkg.Ani.Light")
	local attr = self:GetAttribute()
	
	local FullProcessBkg = self:GetControlObject("FullProcessBkg")
	if attr.FullProgress then
		self:SetProgress(attr.HighBound - attr.LowBound, false)
		if attr.FullProcessBkgId then
			FullProcessBkg:SetResID(attr.FullProcessBkgId)
		end
	else
		FullProcessBkg:SetVisible(false)
	end
	local text = self:GetControlObject("ProgressText")
	text:SetObjPos2("0", tostring(attr.TextTop), "father.width", "father.height")
end

function SetFloor(self, n)
	n = math.floor(n)
	if n < 0 then
		return
	end
	local attr = self:GetAttribute()
	attr.Floor = n
end

function GetFloor(self)
	local attr = self:GetAttribute()
	return attr.Floor
end

function OnEnableChange(self, enable)
	local attr = self:GetAttribute()
	
	local full = self:GetControlObject("FullBkn")
	local empty = self:GetControlObject("EmptyBkn")
	if enable then
		full:SetTextureID(attr.FullID)
		empty:SetTextureID(attr.EmptyID)
	else
		full:SetTextureID(attr.DisableFullID)
		empty:SetTextureID(attr.DisableEmptyID)
	end
end

function OnVisibleChange(self, visible)
	local attr = self:GetAttribute()

    local textobj = self:GetControlObject("ProgressText")
    textobj:SetVisible(visible)
    local fullobj = self:GetControlObject("FullBkn")
    fullobj:SetVisible(visible)
    local emptyobj = self:GetControlObject("EmptyBkn")
    emptyobj:SetVisible(visible)
end