library(readxl)
library(TSA)
library(dplyr)
library(tseries)
library(forecast)

interest_rates <- read_excel("C:/Users/Fergus/Downloads/b.3.1.xlsx")
colnames(interest_rates)
BTL_Floating <- interest_rates[, c("Reporting date", 
                             "Buy-to-let properties, floating rate, standard or LTV variable, rates on outstanding amounts (%)")]

# converting to time series
ts_BTL_Floating_Rates <- ts(BTL_Floating$`Buy-to-let properties, floating rate, standard or LTV variable, rates on outstanding amounts (%)`, 
                            start=c(2014, 4), frequency=4)

# white noise check
acf(ts_BTL_Floating_Rates, main="ACF of BTL Floating Rates", xlab="Years")
pacf(ts_BTL_Floating_Rates, main = "PACF of BTL Floating Rates", xlab= "Years")
#augmented dickey-fuller
adf.test(ts_BTL_Floating_Rates)

# seasonal difference
SeasonaldiffBTL <- diff(ts_BTL_Floating_Rates, lag = 4, differences = 1)
acf(SeasonaldiffBTL, main="ACF of Seasonal Difference (lag=4)")

####### splitting the dataset so 10% can be left for forecasting
train_BTL <- window(ts_BTL_Floating_Rates, end = c(2023, 4)) # end of 2023 last quarter
test_BTL <- window(ts_BTL_Floating_Rates, start = c(2024, 1)) # start at 2024, first quarter
head(train_BTL)
head(test_BTL)

# line plot until 2024
plot(train_BTL, main="Training Set (First 90%)", 
     xlab="Year", ylab="Interest Rate (%)", col="blue")

# checking stationarity for first 90%
adf.test(train_BTL)


# differencing the series
differenced_BTL_90 <- diff(train_BTL)
plot(differenced_BTL_90, main = "Differenced Training BTL Floating Rates", ylab= "differenced train_BTL", xlab = "Time")
adf.test(differenced_BTL_90)

#after differencing, new ACF,PACF
acf(diff_train_BTL, main="ACF of First Difference", xlab= "Years")
pacf(diff_train_BTL, main="PACF of First Difference", xlab="Years")

# (1,1,0) ARIMA 
fit110 <- Arima(train_BTL, order=c(1,1,0))
summary(fit110)
#AIC(fit110) # -59.67

# residuals
checkresiduals(fit110)

# forecast the next 4 using ARIMA(1,1,0)
forecast_110 <- forecast(fit110, h=4)
plot(forecast_110, xlab = "Year")
lines(test_BTL, col='turquoise4')


# Automatic arima model
ARIMAmodel <- auto.arima(train_BTL)
summary(ARIMAmodel)
checkresiduals(ARIMAmodel)

# Forecasting next 4 periods ARIMA(0,2,1)
forecast_values <- forecast(ARIMAmodel, h=4)
plot(forecast_values)
lines(test_BTL, col='red') 



########## SARIMA: Seasonal ARIMA Model
seasonplot(train_BTL, year.labels=TRUE, main="Seasonal plot (Quarterly Data)")
# automatically fit SARIMA
sarima_model <- auto.arima(train_BTL, seasonal=TRUE)
summary(sarima_model) # identical with ARIMA(0,2,1)

# Forecasting
sarima_forecast <- forecast(sarima_model, h=4)

plot(sarima_forecast, main="SARIMA Forecast")
lines(test_BTL, col="red") # Actual values



