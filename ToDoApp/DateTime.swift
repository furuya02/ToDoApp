import UIKit

class DateTime{
    // クラス変数
    private var _nsdate : NSDate?
    private var _year : Int = 0
    private var _month : Int = 0
    private var _day : Int = 0
    private var _hour : Int = 0
    private var _minute : Int = 0
    private var _sec : Int = 0
    private var _msec : Int = 0
    
    // MARK: - Property
    var year : Int {
        return _year
    }
    var month : Int {
        return _month
    }
    var day : Int {
        return _day
    }
    var hour : Int {
        return _hour
    }
    var minute : Int {
        return _minute
    }
    var sec : Int {
        return _sec
    }
    var nsdate : NSDate?{
        return _nsdate!
    }

    //1970/1/1 00:00:00 からの秒数表現
    var ticks:Int64{
        return Int64(_nsdate!.timeIntervalSince1970)
    }
    //秒差 interval = Int(lastUpdate.timeIntervalSinceDate(t.lastUpdate))
    
    // MARK: - Method
    //formatStr = "yyyy/MM/dd HH:mm:ss"
    func fromString(dateStr:String,formatStr:String){
        var format: NSDateFormatter = NSDateFormatter()
        format.locale     = NSLocale(localeIdentifier: "ja")
        format.dateFormat = formatStr
        set(format.dateFromString(dateStr)!)
    }
    func fromString(dateStr:String){
        self.fromString(dateStr,formatStr: "yyyy/MM/dd HH:mm:ss")
    }
    
    //formatStr "yyyy/MM/dd HH:mm:ss"
    func toString(formatStr:String)-> String{
        let format = NSDateFormatter()
        format.locale = NSLocale(localeIdentifier: "js")
        format.dateFormat = formatStr
        return format.stringFromDate(_nsdate!)
    }
    
    func toString()-> String{
        return self.toString("yyyy/MM/dd HH:mm:ss")
    }
    
    func addYear(year:Int) -> DateTime {
        _year += year
        _nsdate = toNsdate(_year, month: _month, day: _day, hour: _hour, minute: _minute, sec: _sec)
        return self
    }
    
    func addMonth(month:Int) -> DateTime {
        _month += month
        _nsdate = toNsdate(_year, month: _month, day: _day, hour: _hour, minute: _minute, sec: _sec)
        return self
    }
    
    func addDay(day:Int) -> DateTime {
        _day += day
        _nsdate = toNsdate(_year, month: _month, day: _day, hour: _hour, minute: _minute, sec: _sec)
        return self
    }
    
    func addHour(hour:Int) -> DateTime {
        _hour += hour
        _nsdate = toNsdate(_year, month: _month, day: _day, hour: _hour, minute: _minute, sec: _sec)
        return self
    }
    func addMinutes(minute:Int) -> DateTime {
        _minute += minute
        _nsdate = toNsdate(_year, month: _month, day: _day, hour: _hour, minute: _minute, sec: _sec)
        return self
    }
    func addsec(sec:Int) -> DateTime {
        _sec += sec
        _nsdate = toNsdate(_year, month: _month, day: _day, hour: _hour, minute: _minute, sec: _sec)
        return self
    }
    
    

    // MARK: init
    //DateTime() 現在時刻で初期化
    init(){
        set(NSDate())
    }

    //DateTime(NSDate)
    init(nsdate:NSDate){
        set(nsdate)
    }

    //DateTime(1970.1.1 0900 からの経過秒)
    init(ticks:Int64){
        set(NSDate(timeIntervalSince1970:Double(ticks)))
    }
    
    //DateTime(年､月､日)
    init(year:Int,month:Int,day:Int){
        set(year,month: month,day: day,hour: 0,minute: 0,sec: 0)
    }

    //DateTime(年､月､日、時、分、秒)
    init(year:Int,month:Int,day:Int,hour:Int,minute:Int,sec:Int){
        set(year,month: month,day: day,hour: hour,minute: minute,sec: sec)
    }
    
    //クラス変数の初期化
    private func set(year:Int,month:Int,day:Int,hour:Int,minute:Int,sec:Int) {
        _year = year
        _month = month
        _day = day
        _hour = hour
        _minute = minute
        _sec = sec

        _nsdate = toNsdate(_year,month: _month,day: _day,hour: _hour,minute: _minute,sec: _sec)
    }
    
    private func toNsdate(year:Int,month:Int,day:Int,hour:Int,minute:Int,sec:Int) -> NSDate? {
        let components = NSDateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = sec
        
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateFromComponents(components)
    }
    
    private func set(nsdate:NSDate){
        _nsdate = nsdate

        let calendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = calendar.components(
            NSCalendarUnit.CalendarUnitYear |
            NSCalendarUnit.CalendarUnitMonth |
            NSCalendarUnit.CalendarUnitDay |
            NSCalendarUnit.CalendarUnitHour |
            NSCalendarUnit.CalendarUnitMinute |
            NSCalendarUnit.CalendarUnitSecond ,
            fromDate: nsdate)
        
        _year = components.year
        _month = components.month
        _day = components.day
        _hour = components.hour
        _minute = components.minute
        _sec = components.second
        _msec = 0
    }
    
    
    
    
    
    
    
}
