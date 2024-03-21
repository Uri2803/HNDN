
let dataLoveDay = () =>{
    const date = new Date();
    const startDate = {
        year: 2023,
        month: 11,
        day: 18
    }
    const currentDate ={
        year: date.getFullYear(),
        month: date.getMonth(),
        day: date.getDate()
    }

        // Tính số năm
    let year = currentDate.year - startDate.year;

    // Tính số tháng
    let month = currentDate.month - startDate.month + 1;

    // Kiểm tra nếu tháng hiện tại nhỏ hơn tháng bắt đầu
    // trừ đi 1 năm và cộng 12 tháng
    if (currentDate.month < startDate.month) {
        year--;
        month += 12;
    }

    // Tính số ngày
    let day = currentDate.day - startDate.day + 1;

    if (currentDate.day < startDate.day) {
        month--;
        const tempDate = new Date(currentDate.year, currentDate.month, startDate.day);
        day = Math.floor((date - tempDate) / (1000 * 60 * 60 * 24));
    }

    const startTime = new Date(2023, 10, 18);
    const currentTime = new Date;
    const millisecondsPassed = currentTime - startTime;

    const totalDay = Math.floor(millisecondsPassed / (1000 * 60 * 60 * 24));

    return {
        year,
        month,
        day,
        totalDay
    };
}

export default dataLoveDay;