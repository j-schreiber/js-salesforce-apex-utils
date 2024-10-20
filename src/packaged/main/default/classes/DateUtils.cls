public class DateUtils {
    private static Date mockedToday;
    private static Datetime mockedNow;

    public static Date today() {
        if (mockedToday != null && Test.isRunningTest()) {
            return mockedToday;
        }
        return System.today();
    }

    public static Datetime now() {
        if (mockedNow != null && Test.isRunningTest()) {
            return mockedNow;
        }
        return System.now();
    }

    @TestVisible
    private static void setMockToday(Date mockValue) {
        mockedToday = mockValue;
    }

    @TestVisible
    private static void setMockNow(Datetime mockValue) {
        mockedNow = mockValue;
    }
}
