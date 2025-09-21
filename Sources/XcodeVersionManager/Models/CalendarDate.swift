struct CalendarDate: Decodable {
    let year: Int
    let month: Int
    let day: Int
}

extension CalendarDate: Comparable {
    static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        guard lhs.year == rhs.year else { return lhs.year < rhs.year }
        guard lhs.month == rhs.month else { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }
}
