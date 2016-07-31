require 'date'
require 'holidays'
require 'prawn'
require 'awesome_print'

def is_holiday?(date)
	(Holidays.on(date, :us).size > 0) ? true : false
end
def dump(s)
	ap s; exit
end
def mid
		(bounds.width - 5) / 2
end
def holiday(date)
	Holidays.on(date, :us).first[:name]
end
def drawWeekDate(date, s, h, j)
	fill_color case
		when is_holiday?(date)
			"FF0000"
		when date.cwday > 5
			"0000FF"
		else
			"000000"
	end
	word = date.strftime("%A, %-d %B")
	draw_text word, :at => [s + 3, h - 12]
	draw_text holiday(date), :at => [s + 3, h - (12 * 2)] if is_holiday?(date)
	fill_color "CCCCCC" 
	x = (j == 0) ? "(%W, %0j)" : "(%0j)"

	word = date.strftime(x)
	draw_text date.strftime(x), :at => [320 - width_of(word), h - 12]
	fill_color "000000" 
end
def drawMonthDate(date, s, h, j)
	fill_color case
		when is_holiday?(date)
			"FF0000"
		when date.cwday > 5
			"0000FF"
		else
			"000000"
	end
	if is_holiday?(date)
		holiday = holiday(date)
		draw_text date.strftime(holiday),
				:at => [320 - width_of(holiday), h - 14],
				:size => 10,
				:font => 'DroidSans'
	end
	draw_text date.strftime("#{%w(U M T W R F S U)[date.cwday]}"),
			:at => [s + 12,  h - 14],
			:size => 7,
			:font => 'DroidSansMono'

	draw_text date.strftime("%_d %b"),
			:at => [s + 20, h - 14],
			:size => 10,
			:font => 'DroidSansMono'

	font 'DroidSans'
end
def resetStroke
	stroke_color "EEEEEE"
end
def drawGrid(h,r,s,w)
	dash(1, :space => r, :phase => 0)
	stroke_color "888888"
	stroke_horizontal_line s, w, :at => h			
	undash
	resetStroke
end
def wideRule(i=30, s=nil,w=nil,dates=nil)

	s = mid + 36 if s.nil?
	w = bounds.width if w.nil?
	h = bounds.top
	r = bounds.height / i
	
	(i+1).times do |j|
		if dates.is_a? Array
			font_size 10
			date = dates[j]
			unless date.nil?
				drawWeekDate(date, s, h, j)  if i == 7
				drawMonthDate(date, s, h, j) if i >27
			end
		else
			circle    [s + (r/2),h - (r/2)], (r * 0.1) unless j + 1 > i
			rectangle [s + (r/4),h - (r/4)], (r * 0.5),(r * 0.5) unless j + 1 > i
		end
		resetStroke
		if dates.is_a? Array and i > 27 and j < dates.size
			stroke_color "999999" if dates[j].cwday == 1
		end
		stroke_horizontal_line s, w, :at => h unless (dates.is_a? Array and i > 27 and j == 0)
		drawGrid(h,r,s,w)  unless dates.is_a? Array
		h -= r
	end
end
def drawMidline
	stroke_color "888888"
	dash(4, :space => 7, :phase => 0)
	stroke_vertical_line -36, bounds.height + 36, :at => mid
	undash()
	resetStroke
end
def drawMargins
	dash(4, :space => 7, :phase => 0)
	
	resetStroke
	stroke_horizontal_line bounds.left, bounds.width, :at => bounds.bottom
	stroke_horizontal_line bounds.left, bounds.width, :at => bounds.height
	stroke_vertical_line   bounds.left, bounds.height, :at => bounds.top_left
	stroke_vertical_line   bounds.left, bounds.height, :at => bounds.width 
	stroke_vertical_line   bounds.left, bounds.height, :at => mid - 54
	stroke_vertical_line   bounds.left, bounds.height, :at => mid + 36
	stroke_vertical_line   0, bounds.height + 36, :at => mid
	undash()
	
end
def minicalendar(fom)
	eom = Date.new(fom.year, fom.mon, -1)
	sdate = fom - (fom.cwday - 1)
	edate = eom + (7 - eom.cwday)
	edate += 6 if edate < eom
	x = 310
	y = 45
	month = (sdate..edate)
	bweek = sdate.strftime("%W").to_i

	offset = 12
	fill_color "999999"
	7.times do |i|
		date = month.to_a[i]
		j = (offset * (7 - date.cwday))
		a = date.cwday

		d = %w(U M T W R F S U)[a]
		draw_text d,
					:at => [x - j + width_of("11") - width_of(d), y + offset],
					:size => 8,
					:font => 'DroidSansMono'		

	end

 (sdate..edate).each do |date|
 	  word = date.strftime("%_d")
 	  cweek = date.strftime("%W").to_i
 	  j = (offset * (7 - date.cwday))
 	  week_offset = (offset * week_offset(fom,sdate,edate,date)) * 0.8
 	  fill_color case
			when is_holiday?(date)
				"FF6666"
			when date.cwday > 5
				"9999FF"
			when date.mon != fom.mon
				"CCCCCC"
			else
				"999999"
		end
		draw_text word,
			:at => [x - j + width_of("11") - width_of(word), y + week_offset],
			:size => 8,
			:font => 'DroidSansMono'
  end
end
def week_offset(fom,bom,eom,date)
	bweek = bom.cweek
	cweek = date.cweek

	if fom.mon == 12
		cweek = date.cweek + 52 if eom.cweek < fom.cweek
	elsif fom.mon == 1 
		bweek = 0 if bom.mon == 12
		cweek = date.cweek
		cweek = 0 if cweek == 53
	end
	return bweek - cweek
end
def junior
	dash(3, :space => 7, :phase => 7)
end

def getDays(fom,i)
	fomw = fom
	fomw -= (fom.cwday - 1) if i < 27

	days = []
	i.times do
		days << fomw
		fomw += 1
	end
	days
end
def drawMonthTitle(date)
	word = date.strftime("%B %Y")
	cline = (bounds.height / 2) - (width_of(date.strftime("%B %Y")) / 2)
	draw_text word, :at => [8,cline], :rotate => 90, :size => 16
end

def setFont
	font_families.update(
		"DroidSansMono" => {:normal => "fonts/Droid_Sans_Mono/DroidSansMono.ttf"},
		"DroidSans"     => {:normal => "fonts/Droid_Sans/DroidSans.ttf"}
	)
	font 'DroidSans'
end

Prawn::Document.generate(
	"builds/weekly.pdf",
	:margin => [18,18,18,18],
	:page_layout => :landscape
) do
		setFont
		offset = 0
		line_width = 1
		@today = Date.today
		(8..8).to_a.each do |i|
			
			@fom   = Date.new(@today.year,i + offset,1)
			@eom   = Date.new(@today.year,i + offset,-1)

			# Set the Month Calendar View
		  if true
				wideRule(30)
				start_new_page
				drawMonthTitle(@fom)
				
			  @month = getDays(@fom,@eom.day)
				wideRule(30)
			  wideRule(@eom.day, 0, mid - 54, @month)
			  drawMidline
			  start_new_page
			end

			# Set the weekly calendars
			fom = @fom
			5.times do 
				@week = getDays(fom,7)
				drawMidline
				wideRule(30)
				wideRule(7, 0, mid - 54, @week)
				minicalendar(@fom)
				start_new_page
				fom += 7
			end
		end
end