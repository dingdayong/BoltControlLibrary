local function UpdateBtnPos(ctrl)
    local attr = ctrl:GetAttribute()
    local btn = ctrl:GetControlObject("sliderbar.btn")
    local left, top, right, bottom = ctrl:GetObjPos()
    local width, height = right - left, bottom - top
	if attr.Type == 0 then
		width = width - attr.UnValidLength*2
	else
		height = height - attr.UnValidLength*2
	end
    if attr.Type == 0 then
		local centerPos = (width) * (attr.Pos - attr.Min) / (attr.Max - attr.Min) + attr.UnValidLength
		--XLPrint("SliderBar: centerPos = "..tostring(centerPos))
		btn:SetObjPos2(centerPos - (attr.BtnWidth / 2), 1 - (attr.BtnHeight - height + 2) / 2, attr.BtnWidth, attr.BtnHeight)
    else
		local centerPos = (height) * (attr.Pos - attr.Min) / (attr.Max - attr.Min) + attr.UnValidLength
		btn:SetObjPos2(0 - (attr.BtnWidth - width + 2) / 2, centerPos - (attr.BtnHeight / 2), attr.BtnWidth, attr.BtnHeight)
    end
end

local function UpdatePos(ctrl)
    local attr = ctrl:GetAttribute()
    if attr.Pos < attr.Min then
        attr.Pos = attr.Min
    end
    if attr.Pos > attr.Max then
        attr.Pos = attr.Max
    end
    UpdateBtnPos(ctrl)
    ctrl:FireExtEvent("OnSliderChange", attr.Pos)
end

local function SetBtnPos(ctrl, newPos)
    local attr = ctrl:GetAttribute()
    local left, top, right, bottom = ctrl:GetObjPos()
    local width, height = right - left, bottom - top
	if attr.Type == 0 then
		width = width - attr.UnValidLength*2
	else
		height = height - attr.UnValidLength*2
	end
    local length
    if attr.Type == 0 then
        if newPos < 0 then
            newPos = 0
        elseif newPos > width then
            newPos = width
        end
        length = width
    else
        if newPos < 0 then
            newPos = 0
        elseif newPos > height then
            newPos = height
        end
        length = height
    end
    attr.Pos = newPos * (attr.Max - attr.Min) / length + attr.Min
    local btn = ctrl:GetControlObject("sliderbar.btn")
	
	if attr.Type == 0 then
		local centerPos = (width) * (attr.Pos - attr.Min) / (attr.Max - attr.Min) + attr.UnValidLength
		--XLPrint("SliderBar: centerPos = "..tostring(centerPos))
		btn:SetObjPos2(centerPos - (attr.BtnWidth / 2), 1 - (attr.BtnHeight - height + 2) / 2, attr.BtnWidth, attr.BtnHeight)
    else
		local centerPos = (height) * (attr.Pos - attr.Min) / (attr.Max - attr.Min) + attr.UnValidLength
		btn:SetObjPos2(0 - (attr.BtnWidth - width + 2) / 2, centerPos - (attr.BtnHeight / 2), attr.BtnWidth, attr.BtnHeight)
    end
    ctrl:FireExtEvent("OnSliderChange", attr.Pos)
end

function OnPosChange(self)
    UpdateBtnPos(self)
end

function SetRange(self, min, max)
    local attr = self:GetAttribute()
    if min < 0 then
        return
    end
    if max < 0 then
        return
    end
    if min > max then
        return
    end
    attr.Min = min
    attr.Max = max
    UpdatePos(self)
end

function GetRange(self)
    local attr = self:GetAttribute()
    return attr.Min, attr.Max
end

function SetPos(self, pos)
    local attr = self:GetAttribute()
    attr.Pos = pos
    UpdatePos(self)
end

function GetPos(self)
    local attr = self:GetAttribute()
    return attr.Pos
end

function OnBtnLButtonDown(self, x, y)
    local ctrl = self:GetOwnerControl()
    local attr = ctrl:GetAttribute()
    if not attr.Enable then
        return 0, true
    end
	attr.BtnFocus = true
    local left, top, right, bottom = self:GetObjPos()
    attr.TrackMouse = true
    self:SetCaptureMouse(true)
    if attr.Type == 0 then
        attr.TrackMousePos = x + left
    else
        attr.TrackMousePos = y + top
    end
    return 0, true
end

function OnBtnLButtonUp(self, x, y,flags)
    local ctrl = self:GetOwnerControl()
    local attr =ctrl:GetAttribute()
    if not attr.Enable then
        return 0, true
    end
    self:SetCaptureMouse(false)
    attr.TrackMouse = false
    attr.TrackMousePos = 0
	ctrl:FireExtEvent("OnSliderLButtonDown", true, x,y,flags)
    return 0, true
end

function OnBtnMouseMove(self, x, y, flag)
    local ctrl = self:GetOwnerControl()
    local attr = ctrl:GetAttribute()
    if not attr.Enable then
        return 0, true
    end
    if not attr.TrackMouse then
        return 0, true
    end
    
    if BitAnd(flag, 1) == 0 then
        return 0, true
    end
    
    local left,top,right,bottom = self:GetObjPos()
    local widthCenter = (right + left) / 2
    local heightCenter = (bottom + top) / 2

    local offset
    if attr.Type == 0 then
        x = left + x
        offset = x - attr.TrackMousePos
        attr.TrackMousePos = x
    else
        y = top + y
        offset = y - attr.TrackMousePos
        attr.TrackMousePos = y
    end
    
    if offset == 0 then
        return 0, true
    elseif offset < 0 then
        if attr.Pos <= attr.Min then
            return 0, true
        end
    elseif attr.Pos >= attr.Max then
        return 0, true
    end

    if attr.Type == 0 then
        SetBtnPos(ctrl, widthCenter + offset)
    else
        SetBtnPos(ctrl, heightCenter + offset)
    end

    return 0, true
end

function OnLButtonDown(self, x, y,flags)
    local ctrl = self:GetOwnerControl()
	local owner = ctrl:GetOwner()
    local attr = ctrl:GetAttribute()
    if not attr.Enable then
        return
    end
    local left, top, right, bottom = ctrl:GetObjPos()
    local width, height = right - left, bottom - top
    if attr.Type == 0 then
        if x < 0 then
            x = 0
        elseif x > width then
            x = width
        end
		attr.Pos = x * (attr.Max - attr.Min) / width + attr.Min
    else
        if y < 0 then
            y = 0
        elseif y > height then
            y = height
        end
		attr.Pos = y * (attr.Max - attr.Min) / height + attr.Min
    end
   
    local btn = ctrl:GetControlObject("sliderbar.btn")
	local btnLeft, btnTop, btnRight, btnBottom = btn:GetObjPos()
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	posAni:SetTotalTime(300)
	posAni:BindLayoutObj(btn)
	
    if attr.Type == 0 then
        --posAni:SetKeyFrameRect(btnLeft, btnTop, btnRight, btnBottom,x - (attr.BtnWidth / 2), 0 - (attr.BtnHeight - height) / 2, x + (attr.BtnWidth / 2), (attr.BtnHeight + height) / 2)
	    posAni:SetKeyFrameRect(btnLeft, btnTop, btnRight, btnBottom,x - (attr.BtnWidth / 2), btnTop, x + (attr.BtnWidth / 2), (attr.BtnHeight + height) / 2)
    else
		--posAni:SetKeyFrameRect(btnLeft, btnTop, btnRight, btnBottom,0 - (attr.BtnWidth - width) / 2, y - (attr.BtnHeight / 2), (attr.BtnWidth + width) / 2, y + (attr.BtnHeight / 2))
		posAni:SetKeyFrameRect(btnLeft, btnTop, btnRight, btnBottom,btnLeft, y - (attr.BtnHeight / 2), (attr.BtnWidth + width) / 2, y + (attr.BtnHeight / 2))
    end
	
	owner:AddAnimation(posAni)
	posAni:Resume()
	
	ctrl:FireExtEvent("OnSliderChange", attr.Pos)
	attr.BkgFocus = true
	ctrl:FireExtEvent("OnSliderLButtonDown", true, x,y,flags)
end

function Btn__OnLButtonDown(self)
	local ctrl = self:GetOwnerControl()
    local attr = ctrl:GetAttribute()
    if not attr.Enable then
        return 0, true
    end
	attr.BtnFocus = true
end

function Btn__OnFocusChange(self, focus)
	local ctrl = self:GetOwnerControl()
    local attr = ctrl:GetAttribute()
	if not focus then
		attr.BtnFocus = false
		if attr.BkgFocus == false then
			ctrl:FireExtEvent("OnSliderLostFocus")
		end
	end
end

function Bkg__OnFocusChange(self, focus)
	local ctrl = self:GetOwnerControl()
    local attr = ctrl:GetAttribute()
	if not focus then
		attr.BkgFocus = false
		if attr.BtnFocus == false then
			ctrl:FireExtEvent("OnSliderLostFocus")
		end
	end
end

function SetFocus(self, focus)
	 local btn = self:GetControlObject("sliderbar.btn")
	 btn:SetFocus(focus)
	 local attr = self:GetAttribute()
	 attr.BtnFocus = true
end

function OnInitControl(self)
    local attr = self:GetAttribute()
    local bkg = self:GetControlObject("sliderbar.bkg")
    bkg:SetTextureID(attr.BkgID)
    local btn = self:GetControlObject("sliderbar.btn")
    local btnattr = btn:GetAttribute()
    btnattr.NormalBkgID = attr.BtnNormalBkgID
    btnattr.HoverBkgID = attr.BtnHoverBkgID
    btnattr.DownBkgID = attr.BtnDownBkgID
    if attr.BtnDisableBkgID then
        btnattr.DisableBkgID = attr.BtnDisableBkgID
    else
        btnattr.DisableBkgID = attr.BtnNormalBkgID
    end
    btn:SetState(0, true)
    btn:SetEnable(attr.Enable)
    btn:AttachListener("OnMouseMove", false, OnBtnMouseMove)
    btn:AttachListener("OnLButtonDown", false, OnBtnLButtonDown)
    btn:AttachListener("OnLButtonUp", false, OnBtnLButtonUp)
    UpdatePos(self)
	attr.BkgFocus = false
	attr.BtnFocus = false
end

function MoveSliderButtonAni(self)
	local btn = self:GetControlObject("sliderbar.btn")
end

function SetEnable(self, enable)
    local attr = self:GetAttribute()
    attr.Enable = enable
    local btn = self:GetControlObject("sliderbar.btn")
    btn:SetEnable(attr.Enable)
end