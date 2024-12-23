//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#ifdef __MQL5__
#include <mql4compat.mqh>
#include <MT4Orders.mqh>
#endif
#property strict

input string Blank01="=========================================";//================================
input string EASettings="EA Settings:1.2";//Cài đặt EA tổng thể
input int Magic=234; //Mã nhận dạng lệnh
input bool RecordCSV=false;//Ghi file CSV
input double CloseAllWhenDD=6000;//Đóng tất cả khi lỗ đạt mức (0 để vô hiệu hóa)
input double FloatDDLimit=10000;//Giới hạn lỗ nổi tối đa
input double MaxDDLimit=15000;//Giới hạn lỗ tối đa

double MaxFloatLoss=0;//Ghi lại lỗ nổi lớn nhất
bool InvalidResult=false;//Kết quả bị vô hiệu
input bool UseTrailStop=false;//Kích hoạt dừng lỗ theo dõi
input int SLStarts=300;//Vị trí bắt đầu di chuyển dừng lỗ
input int SLPips=80;//Số điểm dừng lỗ di chuyển
input bool DisableRefreashRegisters=true;//Vô hiệu hóa làm mới thông tin vị thế; để tăng tốc độ, đặt là true trong môi trường backtest và sử dụng các hàm tích hợp

input string Blank02="=========================================";//================================
input string LabelIS1="Indicators Select:";//Chọn chỉ báo
input int EnterInd1=1;//Chỉ báo mở lệnh 1 (0: vô hiệu hóa, gợi ý 0/1/7)
input int EnterInd2=1;//Chỉ báo mở lệnh 2 (0: vô hiệu hóa, gợi ý 0/1/7)
input string TFSelectLabel1=""; //0: hiện tại, 1: M1, 2: M5, 3: M15, 4: M30, 5: H1, 6: H4, 7: D1, 8: W1, 9: MN1
input int EnterTFSelect1=8; //Chu kỳ biểu đồ của chỉ báo mở lệnh 1 (gợi ý 2/1/8)
input int EnterTFSelect2=8; //Chu kỳ biểu đồ của chỉ báo mở lệnh 2 (gợi ý 2/1/8)

input string Blank03="=========================================";//================================
input string LabelLS="Lot Size Settings:";//Cài đặt khối lượng lệnh
input double StartLots=0.1;//Khối lượng khởi đầu
input double NextStartLots=0.2;//Khối lượng khởi đầu cho các lệnh tiếp theo
input double MultiplyFactor=1.75;//Hệ số nhân (gợi ý 1.3/0.1/2)
double LotArray[50];//Mặc định tối đa 50 cấp độ

input string Blank04="=========================================";//================================
input string LabelGS="Grid Settings:";//Cài đặt lưới
input double MinimumTP=0.5; //Chốt lời tối thiểu (gợi ý 1/0.5/30)
input double GridAdjustmentFactor=2.5; //Hệ số điều chỉnh lưới (gợi ý 1/0.5/15)
double Distance=0;//Khoảng cách thực tế giữa các cấp độ lưới

input string Blank05="=========================================";//================================
input string LabelTS="Trading Settings:";//Cài đặt giao dịch
input int MaxTrades=10; //Số lượng vị thế tối đa (gợi ý 3/1/10)
input int DueDays=28;//Thời gian giữ lệnh lâu nhất (gợi ý 1/1/28)

input string Blank06="=========================================";//================================
input string LabelBS="Backtest Settings:";//Cài đặt hiệu suất kiểm tra
input bool UseZuluTradeP_N=false;//Áp dụng thuật toán lỗ nổi cộng dồn của ZuluTrade/Myfxbook
input double MinimumSharpeRatioLimit=0;//Giới hạn tỷ lệ Sharpe tối thiểu
double TotalFloatLossOrigin=0; //Tổng lỗ nổi ban đầu
double TotalFloatLossFixed=0; //Tổng lỗ nổi cố định
double TotalFloatProfitOrigin=0; //Tổng lợi nhuận nổi ban đầu
double TotalFloatProfitFixed=0; //Tổng lợi nhuận nổi cố định
input double AUD_1LotKickback = 11.00232;//Hoàn tiền cho 1 lot AUD
input double CAD_1LotKickback = 11.28792;//Hoàn tiền cho 1 lot CAD
input double CHF_1LotKickback = 14.31640;//Hoàn tiền cho 1 lot CHF
input double EUR_1LotKickback = 16.75464;//Hoàn tiền cho 1 lot EUR
input double GBP_1LotKickback = 18.98400;//Hoàn tiền cho 1 lot GBP
input double NZD_1LotKickback = 10.06880;//Hoàn tiền cho 1 lot NZD
input double USD_1LotKickback = 14.00000;//Hoàn tiền cho 1 lot USD
double LotKickback=14;//Hoàn tiền mặc định cho 1 lot
double TotalKickback=0;//Tổng hoàn tiền
double TotalLots=0;//Tổng khối lượng lệnh
int TotalTrades= 0;//Tổng số giao dịch

input double ExtraCommissionMultiply=3;//Hệ số nhân phí hoa hồng
input double AUD_1LotCommission = 7.82750;//Phí hoa hồng thêm cho 1 lot AUD
input double CAD_1LotCommission = 7.75750;//Phí hoa hồng thêm cho 1 lot CAD
input double CHF_1LotCommission = 10.6005;//Phí hoa hồng thêm cho 1 lot CHF
input double EUR_1LotCommission = 12.4055;//Phí hoa hồng thêm cho 1 lot EUR
input double GBP_1LotCommission = 13.9020;//Phí hoa hồng thêm cho 1 lot GBP
input double NZD_1LotCommission = 7.28900;//Phí hoa hồng thêm cho 1 lot NZD
input double USD_1LotCommission = 10.0000;//Phí hoa hồng thêm cho 1 lot USD
double ExtraCommission=10;//Phí hoa hồng thêm mỗi lot

input string Blank07="=========================================";//================================
input string LabelIS2="Indicator Settings:";//Cài đặt chỉ báo

input string IndUse="";//Cách sử dụng chỉ báo
input string FixedGrid_Settings="=== Fixed Grid Settings===";//Cài đặt lưới cố định

input string FastMA_Settings="=== Fast Moving Average Settings===";//Cài đặt MA nhanh
input string FastMA_TFSelectLabel=""; //0: hiện tại, 1: M1, 2: M5, 3: M15, 4: M30, 5: H1, 6: H4, 7: D1, 8: W1, 9: MN1
input int FastMAPeriod=20; // Chu kỳ MA
input ENUM_MA_METHOD FastMAMethod=MODE_SMA; // Phương pháp MA (0: đơn giản, 1: hàm mũ, 2: mượt, 3: tuyến tính)
input int FastMAPrice=PRICE_CLOSE; // Giá áp dụng (0: đóng, 1: mở, 2: cao nhất, 3: thấp nhất, 4: trung bình, 5: điển hình, 6: trọng số)
input int FastMAShift=1;//Dịch chuyển

input string MediumMA_Settings="=== Medium Moving Average Settings===";//Cài đặt MA trung bình
input int MediumMAPeriod=50; // Chu kỳ MA
input ENUM_MA_METHOD MediumMAMethod=MODE_SMA; // Phương pháp MA
input int MediumMAPrice=PRICE_CLOSE; // Giá áp dụng
input int MediumMAShift=1;//Dịch chuyển

input string SlowMA_Settings="=== Slow Moving Average Settings===";//Cài đặt MA chậm
input int SlowMAPeriod=100; // Chu kỳ MA
input ENUM_MA_METHOD SlowMAMethod=MODE_SMA; // Phương pháp MA
input int SlowMAPrice=PRICE_CLOSE; // Giá áp dụng
input int SlowMAShift=1;//Dịch chuyển

input string MACD_Settings="=== MACD Settings===";//Cài đặt MACD
input int MACDFast=12; // Chu kỳ nhanh MACD
input int MACDSlow=26; // Chu kỳ chậm MACD
input int MACDSignal=9; // Chu kỳ tín hiệu MACD
input int MACDPrice=PRICE_CLOSE; // Giá áp dụng
input int MACDShift=1;//Dịch chuyển

input string ADX_Settings="=== ADX Settings===";//Cài đặt ADX
input int ADXPeriod=14; // Chu kỳ ADX
input int ADXShift=1;//Dịch chuyển

input string SAR_Settings="=== SAR Settings===";//Cài đặt SAR
input double SARStep=0.02; // Bước SAR
input double SARMaximum=0.2; // Giá trị tối đa SAR
input int SARShift=1;//Dịch chuyển

input string OsMA_Settings="=== OsMA Settings===";//Cài đặt OsMA
input int OsMAFast= 12; // Chu kỳ nhanh OsMA
input int OsMASlow= 26; // Chu kỳ chậm OsMA
input int OsMASignal=9; // Chu kỳ tín hiệu OsMA
input int OsMAPrice=PRICE_CLOSE; // Giá áp dụng
input int OsMAShift=1;//Dịch chuyển

bool NotInNewsTime=true; //Không giao dịch trong thời gian tin tức

ENUM_TIMEFRAMES IndEnterTF1= 0; // Chu kỳ thời gian của chỉ báo mở lệnh 1
ENUM_TIMEFRAMES IndEnterTF2= 0; // Chu kỳ thời gian của chỉ báo mở lệnh 2
int NextOperateCount=0; // Số lượng lần thực hiện tiếp theo

string EnterInd1Name; // Tên của chỉ báo mở lệnh 1
string EnterInd2Name; // Tên của chỉ báo mở lệnh 2

int handle_FastMAEnter1, handle_FastMAEnter2; // Handle của chỉ báo MA nhanh
int handle_MediumMAEnter1, handle_MediumMAEnter2; // Handle của chỉ báo MA trung bình
int handle_SlowMAEnter1, handle_SlowMAEnter2; // Handle của chỉ báo MA chậm
int handle_MACDEnter1, handle_MACDEnter2; // Handle của chỉ báo MACD
int handle_ADXEnter1, handle_ADXEnter2; // Handle của chỉ báo ADX
int handle_SAREnter1, handle_SAREnter2; // Handle của chỉ báo SAR
int handle_OsMAEnter1, handle_OsMAEnter2; // Handle của chỉ báo OsMA
int handle_ATR; // Handle của chỉ báo ATR

datetime OpenTimeFirst=0; // Thời gian mở lệnh đầu tiên

int BuyTicket[50], SellTicket[50]; // Mảng lưu các mã lệnh mua và bán
double BuyLot[50], SellLot[50]; // Mảng lưu khối lượng lệnh mua và bán
double BuyPrice[50], SellPrice[50]; // Mảng lưu giá lệnh mua và bán
double BuyMin[50], SellMin[50]; // Giá thấp nhất cho lệnh mua và bán
double BuyMax[50], SellMax[50]; // Giá cao nhất cho lệnh mua và bán
double BuyPrice_x_Lot, SellPrice_x_Lot; // Giá mua và bán nhân với khối lượng
double AverageBuyPrice, AverageSellPrice; // Giá trung bình của lệnh mua và bán
double MinimumTargetBuyTP; // Mục tiêu chốt lời tối thiểu cho lệnh mua
double MinimumTargetSellTP; // Mục tiêu chốt lời tối thiểu cho lệnh bán

//******************** Thanh ghi ***********************************
int OrdersTotalByThisEA=0; // Tổng số lệnh được EA quản lý
datetime Time_Current=0; // Thời gian hiện tại
int BuyOrdersCount=0, SellOrdersCount=0; // Số lượng lệnh mua và bán
double LastBuyOrderOpenPrice=0, LastSellOrderOpenPrice=0; // Giá mở lệnh mua và bán cuối cùng
double BuyLots=0, SellLots=0; // Tổng khối lượng lệnh mua và bán
datetime FirstBuyOrderTime=0, FirstSellOrderTime=0; // Thời gian lệnh mua và bán đầu tiên
datetime LastBuyTime=0, LastSellTime=0; // Thời gian lệnh mua và bán cuối cùng

datetime NextOperateTime=0; // Thời điểm EA thực hiện lệnh tiếp theo
int StatCloseHandle; // Handle của file thống kê
int PlaceOrderLimit=900; // Giới hạn khoảng cách giữa các lần đặt lệnh

bool isTesting=false; // Đánh dấu môi trường kiểm tra
bool isVisualMode=false; // Đánh dấu chế độ kiểm tra trực quan
bool OneTimeInit=true; // Đánh dấu việc khởi tạo một lần duy nhất
double initBalance=0; // Số dư ban đầu
string OrderCommentBuy="", OrderCommentSell=""; // Ghi chú cho lệnh mua và bán
string StatFile_Close=""; // Tên file thống kê
double Point; // Độ chính xác của giá

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(600); // Cài đặt bộ đếm thời gian mỗi 5 phút (300 giây
   Point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   HideTestIndicators(true); // Ẩn chỉ báo (MT5 không hỗ trợ, bỏ qua)

   isTesting=(IsTesting() || IsOptimization() || IsVisualMode());
   isVisualMode=IsVisualMode();
   // Đánh dấu môi trường kiểm tra hoặc tối ưu hóa, bỏ qua một số bước không cần thiết

   switch(EnterTFSelect1)
     {
      case 0:IndEnterTF1=PERIOD_CURRENT;break;
      case 1:IndEnterTF1=PERIOD_M1;break;
      case 2:IndEnterTF1=PERIOD_M5;break;
      case 3:IndEnterTF1=PERIOD_M15;break;
      case 4:IndEnterTF1=PERIOD_M30;break;
      case 5:IndEnterTF1=PERIOD_H1;break;
      case 6:IndEnterTF1=PERIOD_H4;break;
      case 7:IndEnterTF1=PERIOD_D1;break;
      case 8:IndEnterTF1=PERIOD_W1;break;
      case 9:IndEnterTF1=PERIOD_MN1;break;
      default:{Print("Lỗi chu kỳ mở lệnh");ExpertRemove();}break;
     }
   switch(EnterTFSelect2)
     {
      case 0:IndEnterTF2=PERIOD_CURRENT;break;
      case 1:IndEnterTF2=PERIOD_M1;break;
      case 2:IndEnterTF2=PERIOD_M5;break;
      case 3:IndEnterTF2=PERIOD_M15;break;
      case 4:IndEnterTF2=PERIOD_M30;break;
      case 5:IndEnterTF2=PERIOD_H1;break;
      case 6:IndEnterTF2=PERIOD_H4;break;
      case 7:IndEnterTF2=PERIOD_D1;break;
      case 8:IndEnterTF2=PERIOD_W1;break;
      case 9:IndEnterTF2=PERIOD_MN1;break;
      default:{Print("Lỗi chu kỳ mở lệnh");ExpertRemove();}break;
     }

   StatFile_Close=
                  "Đóng lệnh,"+Symbol()
                  +",Hệ số nhân="+DoubleToString(MultiplyFactor,2)
                  +",Số cấp tối đa="+IntegerToString(MaxTrades)
                  +",Chốt lời="+DoubleToString(MinimumTP,2)
                  +",Khoảng cách lưới="+DoubleToString(GridAdjustmentFactor,2)
                  +",Chỉ báo mở lệnh="+EnterInd1Name
                  +",Chu kỳ chỉ báo="+IntegerToString(IndEnterTF1)
                  +".csv";

   // Môi trường kiểm tra: số chữ số thập phân của khối lượng lệnh là 1; chế độ thực là 2
   int LotsDigits=2;
   if(isTesting)
      LotsDigits=1;

   Print("Khối lượng tối thiểu: ",MarketInfo(Symbol(),MODE_MINLOT)," Bước khối lượng:",MarketInfo(Symbol(),MODE_LOTSTEP));

   LotArray[0]=StartLots;
   for(int i=1;i<=MaxTrades;i++) // Mảng khối lượng lệnh tiếp theo, mặc định bắt đầu từ 0.02 lot
     {
      LotArray[i]=NormalizeDouble(NextStartLots*MathPow(MultiplyFactor,i-1),LotsDigits);
      // Mảng khối lượng lệnh tiếp theo
      Print("Lệnh ",i," Vol: ",DoubleToString(LotArray[i],3) );
     }
   if(LotArray[0]<MarketInfo(Symbol(),MODE_MINLOT))
     {
      Alert("Khối lượng khởi đầu thấp hơn mức tối thiểu cho phép của sàn");
      ExpertRemove();
     }
   if(StringFind(Symbol(),"AUD")==0) {LotKickback = AUD_1LotKickback;ExtraCommission = AUD_1LotCommission;}
   if(StringFind(Symbol(),"CAD")==0) {LotKickback = CAD_1LotKickback;ExtraCommission = CAD_1LotCommission;}
   if(StringFind(Symbol(),"CHF")==0) {LotKickback = CHF_1LotKickback;ExtraCommission = CHF_1LotCommission;}
   if(StringFind(Symbol(),"EUR")==0) {LotKickback = EUR_1LotKickback;ExtraCommission = EUR_1LotCommission;}
   if(StringFind(Symbol(),"GBP")==0) {LotKickback = GBP_1LotKickback;ExtraCommission = GBP_1LotCommission;}
   if(StringFind(Symbol(),"NZD")==0) {LotKickback = NZD_1LotKickback;ExtraCommission = NZD_1LotCommission;}
   if(StringFind(Symbol(),"USD")==0) {LotKickback = USD_1LotKickback;ExtraCommission = USD_1LotCommission;}
   // Tính toán hoa hồng hoàn trả trong môi trường backtest

   if(RecordCSV)
     {
      StatCloseHandle=FileOpen(StatFile_Close,FILE_WRITE|FILE_CSV,',');
      // Xử lý file thống kê đóng lệnh
      FileWrite(StatCloseHandle,"Số thứ tự","Thời gian mở lệnh","Thời gian đóng lệnh","Cặp tiền tệ","Loại","Khối lượng",
                                "Dừng lỗ","Chốt lời","Giá mở","Giá đóng","Phí","Qua đêm","Thời gian giữ lệnh (giờ)",
                                "Số điểm","Lợi nhuận giữ lệnh","Lợi nhuận đóng lệnh (bao gồm phí)","Lợi nhuận bao gồm hoàn trả (bao gồm phí)",
                                "Hoàn trả","Tổng hoàn trả","Ký quỹ sử dụng","Số dư","Giá trị tài khoản",
                                "Giá trị bao gồm hoàn trả","Số dư bao gồm hoàn trả","Lỗ nổi lớn nhất","Thứ tự mở lệnh",
                                "Lợi nhuận nổi cao nhất","Lỗ nổi lớn nhất","Lợi nhuận đóng lệnh");
      FileClose(StatCloseHandle);
      // Ghi tiêu đề file thống kê và đóng file
      StatCloseHandle=FileOpen(StatFile_Close,FILE_READ|FILE_WRITE|FILE_CSV,',');
      FileSeek(StatCloseHandle,0,SEEK_END);
      // Mở lại file thống kê đóng lệnh
     }
   OpenTimeFirst=StringToTime(TimeToStr(TimeCurrent(),TIME_DATE));
   // Ngày hiện tại, bỏ qua thời gian chính xác
   NextOperateTime=OpenTimeFirst; // Thời điểm thực hiện lần đầu
   Time_Current=TimeCurrent();
   initBalance=AccountBalance(); // Số dư khởi tạo

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL5__ 
   switch(EnterInd1)
     {
      case 0:break;
      case 1:handle_FastMAEnter1=iMA(NULL,IndEnterTF1,FastMAPeriod,0,FastMAMethod,FastMAPrice);break;
      case 2:handle_MediumMAEnter1=iMA(NULL,IndEnterTF1,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice);break;
      case 3:handle_SlowMAEnter1=iMA(NULL,IndEnterTF1,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice);break;
      case 4:handle_MACDEnter1=iMACD(NULL,IndEnterTF1,MACDFast,MACDSlow,MACDSignal,MACDPrice);break;
      case 5:handle_ADXEnter1=iADX(NULL,IndEnterTF1,ADXPeriod);break;
      case 6:handle_SAREnter1=iSAR(NULL,IndEnterTF1,SARStep,SARMaximum);break;
      case 7:handle_OsMAEnter1=iOsMA(NULL,IndEnterTF1,OsMAFast,OsMASlow,OsMASignal,OsMAPrice);break;
      default:break;
     }
   switch(EnterInd2)
     {
      case 0:break;
      case 1:handle_FastMAEnter2=iMA(NULL,IndEnterTF2,FastMAPeriod,0,FastMAMethod,FastMAPrice);break;
      case 2:handle_MediumMAEnter2=iMA(NULL,IndEnterTF2,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice);break;
      case 3:handle_SlowMAEnter2=iMA(NULL,IndEnterTF2,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice);break;
      case 4:handle_MACDEnter2=iMACD(NULL,IndEnterTF2,MACDFast,MACDSlow,MACDSignal,MACDPrice);break;
      case 5:handle_ADXEnter2=iADX(NULL,IndEnterTF2,ADXPeriod);break;
      case 6:handle_SAREnter2=iSAR(NULL,IndEnterTF2,SARStep,SARMaximum);break;
      case 7:handle_OsMAEnter2=iOsMA(NULL,IndEnterTF2,OsMAFast,OsMASlow,OsMASignal,OsMAPrice);break;
      default:break;
     }
   handle_ATR=iATR(Symbol(),PERIOD_H1,500);
#endif
   return (INIT_SUCCEEDED);

  }


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   float a;
   a = a + a;
    // In giá trị mỗi 5 phút
   //  Print("MinimumTargetBuyTP= ", MinimumTargetBuyTP, ", BuyOrdersCount= ", BuyOrdersCount);
   //  Print("MinimumTargetSellTP= ", MinimumTargetSellTP, ", SellOrdersCount= ", SellOrdersCount);
}  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

    EventKillTimer(); // Hủy bộ đếm thời gian khi EA dừng
//ObjectsDeleteAll();
//清空所有图标夹对象
   string FinalStatFile=
                        "最终,"+Symbol()
                        +",翻倍="+DoubleToString(MultiplyFactor,2)
                        +",最大层数="+IntegerToString(MaxTrades)
                        +",止盈="+DoubleToString(MinimumTP,2)
                        +",加仓间隔="+DoubleToString(GridAdjustmentFactor,2)
                        +",开仓指标="+EnterInd1Name
                        +",开仓指标周期="+IntegerToString(IndEnterTF1)
                        +".csv";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(RecordCSV)
     {
      int FinalStatHandle=FileOpen(FinalStatFile,FILE_WRITE|FILE_CSV,',');
      //MT4最终平仓统计 可选功能
      FileWrite(FinalStatHandle,
                "起始资金(STAT_INITIAL_DEPOSIT)",
                "总净盈利(STAT_PROFIT)",
                "毛盈利(STAT_GROSS_PROFIT)",
                "毛亏损(STAT_GROSS_LOSS)",
                "最大单笔盈利(STAT_MAX_PROFITTRADE)",
                "最大单笔亏损(STAT_MAX_LOSSTRADE)",
                "最大连续盈利金额(STAT_CONPROFITMAX)",
                "最大连续盈利次数(STAT_CONPROFITMAX_TRADES)",
                "最多连续盈利金额(STAT_MAX_CONWINS)",
                "最多连续亏损次数(STAT_MAX_CONPROFIT_TRADES)",
                "最大连续亏损金额(STAT_CONLOSSMAX)",
                "最大连续亏损次数(STAT_CONLOSSMAX_TRADES)",
                "最多连续亏损金额(STAT_MAX_CONLOSSES)",
                "最多连续亏损次数(STAT_MAX_CONLOSS_TRADES)",
                "绝对亏损(STAT_BALANCEMIN)",
                "最大余额亏损(STAT_BALANCE_DD)",
                "最大余额亏损比例(STAT_BALANCEDD_PERCENT)",
                "最大余额亏损比例DDREL(STAT_BALANCE_DDREL_PERCENT)",
                "最大余额相对亏损(STAT_BALANCE_DD_RELATIVE)",
                "最低净值(STAT_EQUITYMIN)",
                "净值最大亏损(STAT_EQUITY_DD)",
                "净值最大亏损比例(STAT_EQUITYDD_PERCENT)",
                "净值最大亏损比例DDREL(STAT_EQUITY_DDREL_PERCENT)",
                "净值相对亏损比例(STAT_EQUITY_DD_RELATIVE)",
                "预期盈利(STAT_EXPECTED_PAYOFF)",
                "盈利(STAT_PROFIT_FACTOR)",
                "最低可用预付款(STAT_MIN_MARGINLEVEL)",
                "OnTester数值(STAT_CUSTOM_ONTESTER)",
                "交易次数(STAT_TRADES)",
                "盈利次数(STAT_PROFIT_TRADES)",
                "亏损次数(STAT_LOSS_TRADES)",
                "空单数量(STAT_SHORT_TRADES)",
                "多单数量(STAT_LONG_TRADES)",
                "空单盈利(STAT_PROFIT_SHORTTRADES)",
                "多单盈利(STAT_PROFIT_LONGTRADES)",
                "平均盈利交易(STAT_PROFITTRADES_AVGCON)",
                "平均亏损交易(STAT_LOSSTRADES_AVGCON)"
                );

      FileClose(FinalStatHandle);
      //写入最终平仓统计文件头并且关闭
      FinalStatHandle=FileOpen(FinalStatFile,FILE_READ|FILE_WRITE|FILE_CSV,',');
      FileSeek(FinalStatHandle,0,SEEK_END);
      //再次打开最终统计文件并定位到底部
      FileWrite(FinalStatHandle,
                TesterStatistics(STAT_INITIAL_DEPOSIT),
                TesterStatistics(STAT_PROFIT),
                TesterStatistics(STAT_GROSS_PROFIT),
                TesterStatistics(STAT_GROSS_LOSS),
                TesterStatistics(STAT_MAX_PROFITTRADE),
                TesterStatistics(STAT_MAX_LOSSTRADE),
                TesterStatistics(STAT_CONPROFITMAX),
                TesterStatistics(STAT_CONPROFITMAX_TRADES),
                TesterStatistics(STAT_MAX_CONWINS),
                TesterStatistics(STAT_MAX_CONPROFIT_TRADES),
                TesterStatistics(STAT_CONLOSSMAX),
                TesterStatistics(STAT_CONLOSSMAX_TRADES),
                TesterStatistics(STAT_MAX_CONLOSSES),
                TesterStatistics(STAT_MAX_CONLOSS_TRADES),
                TesterStatistics(STAT_BALANCEMIN),
                TesterStatistics(STAT_BALANCE_DD),
                TesterStatistics(STAT_BALANCEDD_PERCENT),
                TesterStatistics(STAT_BALANCE_DDREL_PERCENT),
                TesterStatistics(STAT_BALANCE_DD_RELATIVE),
                TesterStatistics(STAT_EQUITYMIN),
                TesterStatistics(STAT_EQUITY_DD),
                TesterStatistics(STAT_EQUITYDD_PERCENT),
                TesterStatistics(STAT_EQUITY_DDREL_PERCENT),
                TesterStatistics(STAT_EQUITY_DD_RELATIVE),
                TesterStatistics(STAT_EXPECTED_PAYOFF),
                TesterStatistics(STAT_PROFIT_FACTOR),
                TesterStatistics(STAT_MIN_MARGINLEVEL),
                TesterStatistics(STAT_CUSTOM_ONTESTER),
                TesterStatistics(STAT_TRADES),
                TesterStatistics(STAT_PROFIT_TRADES),
                TesterStatistics(STAT_LOSS_TRADES),
                TesterStatistics(STAT_SHORT_TRADES),
                TesterStatistics(STAT_LONG_TRADES),
                TesterStatistics(STAT_PROFIT_SHORTTRADES),
                TesterStatistics(STAT_PROFIT_LONGTRADES),
                TesterStatistics(STAT_PROFITTRADES_AVGCON),
                TesterStatistics(STAT_LOSSTRADES_AVGCON)
                );
      FileClose(FinalStatHandle);
      //写入对应项目并且关闭
      FileClose(StatCloseHandle);

      string FinalStatLiteFile=
                               "简要,"+Symbol()
                               +",翻倍="+DoubleToString(MultiplyFactor,2)
                               +",最大层数="+IntegerToString(MaxTrades)
                               +",止盈="+DoubleToString(MinimumTP,2)
                               +",加仓间隔="+DoubleToString(GridAdjustmentFactor,2)
                               +",开仓指标="+EnterInd1Name
                               +",开仓指标周期="+IntegerToString(IndEnterTF1)
                               +".csv";
      int FinalStatLiteHandle=FileOpen(FinalStatLiteFile,FILE_READ|FILE_WRITE|FILE_CSV,',');
      FileWrite(FinalStatLiteHandle,
                "货币","最大浮亏","前台盈利","台+后台盈利","累计返佣","总手数","交易次数"
                );
      FileWrite(FinalStatLiteHandle,
                Symbol(),
                NormalizeDouble(MaxFloatLoss,2),
                //浮亏
                NormalizeDouble(AccountEquity()-initBalance,2),
                //前台盈利
                NormalizeDouble(AccountEquity()-initBalance+TotalKickback,2),
                //前台+后台盈利
                NormalizeDouble(TotalKickback,2),
                //累计返佣
                TotalLots,
                TotalTrades
                );
      FileClose(FinalStatLiteHandle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void SetHLine(color cl,string nm="",double p1=0,int st=0,int wd=1)
  {
   Print("SetHLine: Tên = ", nm, ", Giá = ", p1, ", Màu = ", cl, ", Kiểu = ", st, ", Độ dày = ", wd);
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_HLINE,0,0,0);
   ObjectSetDouble(0,nm,OBJPROP_PRICE,p1);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,cl);
   ObjectSetInteger(0,nm,OBJPROP_STYLE,st);
   ObjectSetInteger(0,nm,OBJPROP_WIDTH,wd);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   static int LastOrdersTotal; // Lưu số lượng lệnh mở lần cuối
   static double BuySL, SellSL; // Mức cắt lỗ cho lệnh mua và bán
   static double accountProfit; // Lợi nhuận tài khoản hiện tại
   accountProfit=AccountInfoDouble(ACCOUNT_PROFIT); // Lấy lợi nhuận tài khoản
   MaxFloatLoss=MathMin(MaxFloatLoss,accountProfit); // Lưu lỗ nổi lớn nhất

#ifdef __MQL5__
   // Xử lý các hành động cụ thể của MQL5 (để trống ở đây)
#endif

   Time_Current=TimeCurrent();
   // Lấy thời gian hiện tại và lưu vào biến, tránh gọi hàm nhiều lần làm giảm tốc độ

   if(CloseAllWhenDD>0 && accountProfit<-CloseAllWhenDD)
     {
      // Nếu thiết lập mức đóng tất cả khi thua lỗ đạt mức cụ thể
      CloseAllOrders(); // Đóng tất cả lệnh
     }
   if(CloseAllWhenDD<=0 && MaxFloatLoss<-FloatDDLimit)
     {
      // Nếu không thiết lập đóng tự động và lỗ nổi vượt quá giới hạn cho phép
      InvalidResult=true; // Đánh dấu kết quả giao dịch không hợp lệ
      CloseAllOrders(); // Đóng tất cả lệnh
      ExpertRemove(); // Xóa EA
     }

   if(UseZuluTradeP_N) ZuluTrade(); // Tính toán hiệu suất theo phương pháp ZuluTrade

   if(UseTrailStop)
     {
      Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK); // Lấy giá mua (Ask)
      Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID); // Lấy giá bán (Bid)

      if(Bid-AverageBuyPrice>=Point*SLStarts && BuyOrdersCount>0)
        {
         // Nếu giá bán đã vượt quá giá mua trung bình + khoảng dừng cắt lỗ và có lệnh mua
         if(BuySL==0) BuySL=Bid-Point*SLPips; // Thiết lập cắt lỗ lần đầu
         BuySL=MathMax(BuySL, Bid-Point*SLPips); // Điều chỉnh mức cắt lỗ
         if(isVisualMode) SetHLine(clrRed, "Buy", BuySL, 0, 1); // Hiển thị mức cắt lỗ trên biểu đồ
        }
      if(AverageSellPrice-Ask>=Point*SLStarts && SellOrdersCount>0)
        {
         // Nếu giá mua đã vượt quá giá bán trung bình + khoảng dừng cắt lỗ và có lệnh bán
         if(SellSL==0) SellSL=Ask+Point*SLPips; // Thiết lập cắt lỗ lần đầu
         SellSL=MathMin(SellSL, Ask+Point*SLPips); // Điều chỉnh mức cắt lỗ
         if(isVisualMode) SetHLine(clrRed, "Sell", SellSL, 0, 1); // Hiển thị mức cắt lỗ trên biểu đồ
        }
      if(BuySL>0 && Bid<BuySL && BuyOrdersCount>0)
        {
         // Nếu mức cắt lỗ mua bị phá vỡ
         Print("BuySL=", BuySL, ",Bid=", Bid, ",Point*SLPips=", Point*SLPips);
         BuySL=0; // Đặt lại mức cắt lỗ
         CloseBuyOrders(); // Đóng tất cả lệnh mua
         // if(isVisualMode) SetHLine(clrRed, "Buy", 0, 0, 1); // Loại bỏ mức cắt lỗ trên biểu đồ
        }
      if(SellSL>0 && Ask>SellSL && SellOrdersCount>0)
        {
         // Nếu mức cắt lỗ bán bị phá vỡ
         Print("SellSL=", SellSL, ",Ask=", Ask, ",Point*SLPips=", Point*SLPips);
         SellSL=0; // Đặt lại mức cắt lỗ
         CloseSellOrders(); // Đóng tất cả lệnh bán
         // if(isVisualMode) SetHLine(clrRed, "Sell", 0, 0, 1); // Loại bỏ mức cắt lỗ trên biểu đồ
        }
     }

   if(Time_Current >= NextOperateTime)
      // Nếu đến thời gian cho lần xử lý tiếp theo
     {
      if(TesterStatistics(STAT_EQUITY_DD) > MaxDDLimit)
        {
         // Nếu mức Drawdown vượt quá giới hạn tối đa
         InvalidResult=true; // Đánh dấu kết quả không hợp lệ
         CloseAllOrders(); // Đóng tất cả lệnh
         ExpertRemove(); // Gỡ EA
        }

      if(OneTimeInit)
         // Thực hiện các thiết lập ban đầu chỉ một lần
        {
#ifdef __MQL5__
         Distance=IndGet(handle_ATR, 0, 1); // Lấy khoảng cách ATR (MQL5)
#endif
#ifdef __MQL4__
         Distance=iATR(Symbol(), PERIOD_H1, 500, 1); // Lấy khoảng cách ATR (MQL4)
#endif
         OneTimeInit=false; // Đánh dấu hoàn thành thiết lập
        }

#ifdef __MQL5__
      Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK); // Cập nhật giá Ask (MQL5)
      Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID); // Cập nhật giá Bid (MQL5)
#endif

      if(!DisableRefreashRegisters || !isTesting)
         // Nếu không tắt cập nhật hoặc không ở chế độ kiểm tra
         if(OrdersTotal() != LastOrdersTotal || !isTesting)
           {
            // Chỉ làm mới nếu số lượng lệnh thay đổi
            UpdateRegisters(); // Cập nhật thông tin các lệnh
            LastOrdersTotal=OrdersTotal(); // Lưu số lượng lệnh hiện tại
           }

      if(Bid > MinimumTargetBuyTP && BuyOrdersCount > 0)
        {
         CloseBuyOrders(); // Đóng tất cả lệnh mua khi đạt mục tiêu
        }
      if(Ask < MinimumTargetSellTP && SellOrdersCount > 0)
        {
         CloseSellOrders(); // Đóng tất cả lệnh bán khi đạt mục tiêu
        }

      isNewsRelease(); // Kiểm tra tin tức để quản lý lệnh
      // DueCut(); // Đóng lệnh khi đến hạn

      if(NotInNewsTime)
         // Nếu không phải thời gian công bố tin tức
        {
         if(BuyOrdersCount > 0 && BuyOrdersCount < MaxTrades && Time_Current >= LastBuyTime + PlaceOrderLimit)
            // Nếu có lệnh mua, số lượng nhỏ hơn giới hạn, và thỏa mãn thời gian đặt lệnh tiếp theo
           {
            if(Ask < LastBuyOrderOpenPrice - Distance * GridAdjustmentFactor)
              {
               // Nếu giá giảm đủ để đáp ứng điều kiện bổ sung lệnh mua
               if(Ind(EnterInd1, "Enter1") >= 0)
                  if(Ind(EnterInd2, "Enter2") >= 0)
                     SendBuyOrder(LotArray[BuyOrdersCount], Magic);
               // Gửi lệnh mua
              }
           }
         if(BuyOrdersCount == 0)
           {
            // Nếu không có lệnh mua
            if(Ind(EnterInd1, "Enter1") >= 0)
               if(Ind(EnterInd2, "Enter2") >= 0)
                  SendBuyOrder(LotArray[BuyOrdersCount], Magic);
            // Gửi lệnh mua
           }
         if(SellOrdersCount > 0 && SellOrdersCount < MaxTrades && Time_Current >= LastSellTime + PlaceOrderLimit)
            // Nếu có lệnh bán, số lượng nhỏ hơn giới hạn, và thỏa mãn thời gian đặt lệnh tiếp theo
           {
            if(Bid > LastSellOrderOpenPrice + Distance * GridAdjustmentFactor)
              {
               // Nếu giá tăng đủ để đáp ứng điều kiện bổ sung lệnh bán
               if(Ind(EnterInd1, "Enter1") <= 0)
                  if(Ind(EnterInd2, "Enter2") <= 0)
                     SendSellOrder(LotArray[SellOrdersCount], Magic);
               // Gửi lệnh bán
              }
           }
         if(SellOrdersCount == 0)
           {
            // Nếu không có lệnh bán
            if(Ind(EnterInd1, "Enter1") <= 0)
               if(Ind(EnterInd2, "Enter2") <= 0)
                  SendSellOrder(LotArray[SellOrdersCount], Magic);
            // Gửi lệnh bán
           }
        }
      NextOperateTime = OpenTimeFirst + 300 * NextOperateCount;
      // Tính toán thời gian xử lý tiếp theo (mỗi 300 giây)
      NextOperateCount++; // Tăng số lần xử lý
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendBuyOrder(double lots, int magic)
  {
   // Tạo ghi chú cho lệnh mua (có thể sử dụng số thứ tự của lệnh)
   OrderCommentBuy=IntegerToString(BuyOrdersCount+1);

   // Gửi lệnh mua (OrderSend) và lưu số hiệu lệnh vào mảng BuyTicket
   BuyTicket[BuyOrdersCount]=OrderSend(Symbol(),OP_BUY,lots,Ask,9999,0,0,OrderCommentBuy,magic,0,clrNONE);

   // Lưu số hiệu lệnh vào mảng đăng ký lệnh
   // Thực hiện lệnh mua. Bỏ qua cảnh báo của MT4 khi không kiểm tra kết quả OrderSend và OrderClose.
   // Trong thực tế, trạng thái sẽ được làm mới ở tick tiếp theo, mọi giá trị lỗi đều sẽ được sửa.
   LastBuyTime=Time_Current; // Lưu thời gian hiện tại (trong backtest không cần làm mới)
   BuyLot[BuyOrdersCount]=lots; // Lưu khối lượng lệnh vào mảng đăng ký
   BuyLots=BuyLots+lots; // Cộng dồn tổng khối lượng lệnh mua
   BuyPrice_x_Lot=BuyPrice_x_Lot+lots*Ask; // Cộng dồn tổng (khối lượng mua * giá mua)
   LastBuyOrderOpenPrice=Ask; // Ghi nhận giá mở lệnh mua cuối cùng (dùng cho chiến lược bổ sung)
   AverageBuyPrice=BuyPrice_x_Lot/BuyLots; // Tính giá mua trung bình
   BuyOrdersCount++; // Tăng số lượng lệnh mua
   OrdersTotalByThisEA++; // Tăng tổng số lệnh EA đang giữ
   TotalLots=TotalLots+lots; // Tổng khối lượng lệnh
   TotalTrades++; // Tổng số giao dịch đã thực hiện

   if(BuyOrdersCount==1)
      // Nếu đây là lệnh mua đầu tiên, ghi nhận thời gian đặt lệnh
      FirstBuyOrderTime=Time_Current;

#ifdef __MQL5__
   // Nếu sử dụng MQL5, lấy khoảng cách ATR từ chỉ báo (hàm IndGet)
   Distance=IndGet(handle_ATR,0,1);
#endif
#ifdef __MQL4__
   // Nếu sử dụng MQL4, lấy khoảng cách ATR từ chỉ báo iATR
   Distance=iATR(Symbol(),PERIOD_H1,500,1);
#endif

   // Tính mức chốt lời tối thiểu (MinimumTargetBuyTP)
   MinimumTargetBuyTP=AverageBuyPrice==0 ? 0 : NormalizeDouble(AverageBuyPrice+Distance*MinimumTP,Digits);

   // Ghi nhận giá trị mức chốt lời và số lượng lệnh mua hiện tại để kiểm tra
   Print("SendBuyOrder: MinimumTargetBuyTP= ", MinimumTargetBuyTP, ", BuyOrdersCount= ", BuyOrdersCount);
   float PriceDcaNext = LastBuyOrderOpenPrice - Distance * GridAdjustmentFactor;
   Print("Buy PriceDcaNext= ", PriceDcaNext);
   // SetHLine(clrRed, "PriceDcaNext", PriceDcaNext, 0, 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendSellOrder(double lots,int magic)
  {
//if(SellOrdersCount<3){OrderCommentSell="No";}else{OrderCommentSell="Yes";}
   OrderCommentSell=IntegerToString(SellOrdersCount+1);
   SellTicket[SellOrdersCount]=OrderSend(Symbol(),OP_SELL,lots,Bid,9999,0,0,OrderCommentSell,magic,0,clrNONE);
//做空
   LastSellTime=Time_Current;
   SellLot[SellOrdersCount]=lots;//手数寄存器
   SellLots=SellLots+lots;//总手数
                          //SellPrice[SellOrdersCount]=Bid;//买入价寄存器
   SellPrice_x_Lot=SellPrice_x_Lot+lots*Bid;//累计买入价寄存器
   LastSellOrderOpenPrice=Bid;//最后买入价寄存器
   AverageSellPrice=SellPrice_x_Lot/SellLots;
   SellOrdersCount++;
   OrdersTotalByThisEA++;
   TotalLots=TotalLots+lots;
   TotalTrades++;
   if(SellOrdersCount==1)
      //若是第一单 记录下单时间，此单开仓时间作为判定时间点
      FirstSellOrderTime=Time_Current;
#ifdef __MQL5__
   Distance=IndGet(handle_ATR,0,1);
#endif
#ifdef __MQL4__
   Distance=iATR(Symbol(),PERIOD_H1,500,1);
#endif
   MinimumTargetSellTP=AverageSellPrice==0 ? 0 : NormalizeDouble(AverageSellPrice-Distance*MinimumTP,Digits);
   Print("SendSellOrder: MinimumTargetSellTP= ", MinimumTargetSellTP, ", SellOrdersCount= ", SellOrdersCount);
   float PriceDcaNext = LastBuyOrderOpenPrice + Distance * GridAdjustmentFactor;
   Print("Sell PriceDcaNext= ", PriceDcaNext);
//空单市价已经低于卖出均价+止盈
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyOrders()
// Đóng tất cả các lệnh mua
  {

   Print("CloseBuyOrders ");
   for(int x=BuyOrdersCount-1; x>=0; x--)
     {
      TotalFloatLossFixed = TotalFloatLossFixed + BuyMin[x] - BuyLot[x] * ExtraCommission * ExtraCommissionMultiply;
      // Lỗ đã điều chỉnh với phí giao dịch

      TotalFloatProfitFixed = TotalFloatProfitFixed + BuyMax[x] - BuyLot[x] * ExtraCommission * ExtraCommissionMultiply;
      // Lãi đã điều chỉnh với phí giao dịch

      TotalFloatLossOrigin = TotalFloatLossOrigin + BuyMin[x];
      // Lỗ gốc (không điều chỉnh phí giao dịch)

      TotalFloatProfitOrigin = TotalFloatProfitOrigin + BuyMax[x];
      // Lãi gốc (không điều chỉnh phí giao dịch)

      StatsClose(BuyTicket[x], x+1, BuyMax[x], BuyMin[x]);
      // Ghi nhận thống kê khi đóng lệnh

      OrderClose(BuyTicket[x], BuyLot[x], Bid, 9999, CLR_NONE);
      // Đóng lệnh mua dựa trên số hiệu lệnh (BuyTicket[x])
      // Giá đóng lệnh là giá bán hiện tại (Bid)
      // 9999: Độ trượt giá tối đa
      // CLR_NONE: Không gán màu cho lệnh trong nhật ký

      BuyMin[x] = 0;
      // Xóa giá trị lỗ tối thiểu của lệnh

      BuyMax[x] = 0;
      // Xóa giá trị lãi tối đa của lệnh
     }

   OrdersTotalByThisEA = OrdersTotalByThisEA - BuyOrdersCount;
   // Giảm tổng số lệnh mở của EA

   BuyLots = 0;
   // Đặt lại tổng khối lượng lệnh mua về 0

   BuyPrice_x_Lot = 0;
   // Đặt lại tổng giá trị mua (khối lượng * giá mua)

   BuyOrdersCount = 0;
   // Đặt lại số lượng lệnh mua về 0

   AverageBuyPrice = 0;
   // Đặt lại giá trung bình của các lệnh mua

   LastBuyOrderOpenPrice = 0;
   // Đặt lại giá mở lệnh mua cuối cùng

   FirstBuyOrderTime = 0;
   // Đặt lại thời gian mở lệnh mua đầu tiên
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellOrders()
//有平空单
  {
   Print("CloseSellOrders ");
   for(int x=SellOrdersCount-1;x>=0;x--)
     {
      TotalFloatLossFixed=TotalFloatLossFixed+SellMin[x]-SellLot[x]*ExtraCommission*ExtraCommissionMultiply;
      //点差修正后的浮亏
      TotalFloatProfitFixed=TotalFloatProfitFixed+SellMax[x]-SellLot[x]*ExtraCommission*ExtraCommissionMultiply;
      //点差修正后的浮盈
      TotalFloatLossOrigin=TotalFloatLossOrigin+SellMin[x];
      //原始点差浮亏
      TotalFloatProfitOrigin=TotalFloatProfitOrigin+SellMax[x];
      //原始点差浮盈
      StatsClose(SellTicket[x],x+1,SellMax[x],SellMin[x]);
      //统计平仓
      OrderClose(SellTicket[x],SellLot[x],Bid,9999,CLR_NONE);
      //直接根据单号平仓 忽略MT4警告
      SellMin[x]=0;
      //浮亏寄存器
      SellMax[x]=0;
      //浮盈寄存器
     }
   OrdersTotalByThisEA=OrdersTotalByThisEA-SellOrdersCount;
//修正EA下单总数寄存器
   SellLots=0;
//卖出总手数寄存器
   SellPrice_x_Lot=0;
//清空卖单累计价格寄存器
   SellOrdersCount=0;
//清空卖单数量寄存器
   AverageSellPrice=0;
//清空空单均价寄存器
   LastSellOrderOpenPrice=0;
//清空最后的卖单价格
   FirstSellOrderTime=0;
//首次开仓时间寄存器
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllOrders()
//全部平仓
  {
   CloseBuyOrders();
   CloseSellOrders();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   double OpenAccurate=0,FP_FL_Ratio,CloseAccurate=0,PLNSpeed=0,ProfitMiss=0;
   double result,ZuluTrade_P_L;
   double ExtraCommissionTotal=TotalLots*ExtraCommission*ExtraCommissionMultiply;
   double TotalProfitFixed=AccountInfoDouble(ACCOUNT_EQUITY)-initBalance-ExtraCommissionTotal;
   double TotalProfitOrigin=AccountInfoDouble(ACCOUNT_EQUITY)-initBalance;
   if(TesterStatistics(STAT_EQUITY_DD)>MaxDDLimit)
      InvalidResult=true;
   if(UseZuluTradeP_N)
     {
      OpenAccurate=TotalFloatProfitFixed/(TotalFloatProfitFixed-TotalFloatLossFixed);
      //开仓精度
      FP_FL_Ratio=-TotalFloatProfitFixed/TotalFloatLossFixed;
      //浮盈浮亏比
      CloseAccurate=TotalProfitFixed/TotalFloatProfitFixed;
      //平仓精度
      ProfitMiss=1-CloseAccurate;
      //盈利丢失
      PLNSpeed=-TotalProfitFixed/TotalFloatLossFixed;
      //盈亏速度
      if(PLNSpeed>3)
         InvalidResult=true;
      //ZuluTrade结果异常
     }
   double Performance=TesterStatistics(STAT_SHARPE_RATIO)*OpenAccurate*CloseAccurate;
//综合绩效算法
   if(UseZuluTradeP_N)
      //计算ZuluTrade PLN
     {
      if(InvalidResult || TotalProfitFixed<0 || TesterStatistics(STAT_SHARPE_RATIO)<MinimumSharpeRatioLimit || TotalFloatProfitFixed<0)
        {
         result=MathMax(-0.1,-MathAbs(Performance));
         ZuluTrade_P_L=-MathAbs(PLNSpeed);
        }
      else
        {
         result=MathMax(-0.1,Performance);
         ZuluTrade_P_L=PLNSpeed;
        }
     }
   else
     {
      if(InvalidResult || TotalProfitFixed<0 || TesterStatistics(STAT_SHARPE_RATIO)<MinimumSharpeRatioLimit)
        {
         result=-MathAbs(TotalProfitFixed);
        }
      else
        {
         result=TotalProfitFixed;
        }
     }
   Print("原始点差盈利=",NormalizeDouble(TotalProfitOrigin,0));
   Print("修正后的盈利=",NormalizeDouble(TotalProfitFixed,0));
   Print("原始点差浮亏=",NormalizeDouble(TotalFloatLossOrigin,0));
   Print("修正后的浮亏=",NormalizeDouble(TotalFloatLossFixed,0));
   Print("原始点差浮盈=",NormalizeDouble(TotalFloatProfitOrigin,0));
   Print("修正后的浮盈=",NormalizeDouble(TotalFloatProfitFixed,0));
   Print("平仓精度=",CloseAccurate);
   Print("开仓精度=",OpenAccurate);
   Print("丢失盈利=",ProfitMiss);
   Print("浮盈/浮亏=",FP_FL_Ratio);

   if(UseZuluTradeP_N)
     {
      Print("ZuluTrade 绩效指数=",ZuluTrade_P_L);
     }
   Print("夏普比率=",TesterStatistics(STAT_SHARPE_RATIO));
   Print("综合绩效=",result);
   Print("修正后的盈利=",TotalProfitFixed);
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ind(int IndNumber,string mode)
  {
   if(mode=="Enter1")
     {
      switch(IndNumber)
        {
         case 0:return 0;break;
         case 1:
           {
#ifdef __MQL4__
            double FastMA1=iMA(NULL,IndEnterTF1,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift);
            double FastMA2=iMA(NULL,IndEnterTF1,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift+1);
#endif
#ifdef __MQL5__
            double FastMA1=IndGet(handle_FastMAEnter1,0,FastMAShift);
            double FastMA2=IndGet(handle_FastMAEnter1,0,FastMAShift+1);
#endif
            if(FastMA1>FastMA2)
               return 1;
            else
               return -1;
           }
         break;
         case 2:
           {
#ifdef __MQL4__
            double MediumMA1=iMA(NULL,IndEnterTF1,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift);
            double MediumMA2=iMA(NULL,IndEnterTF1,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift+1);
#endif
#ifdef __MQL5__
            double MediumMA1=IndGet(handle_MediumMAEnter1,0,MediumMAShift);
            double MediumMA2=IndGet(handle_MediumMAEnter1,0,MediumMAShift+1);
#endif
            if(MediumMA1>MediumMA2)
               return 1;
            else
               return -1;
           }
         break;
         case 3:
           {
#ifdef __MQL4__
            double SlowMA1=iMA(NULL,IndEnterTF1,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift);
            double SlowMA2=iMA(NULL,IndEnterTF1,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift+1);
#endif
#ifdef __MQL5__
            double SlowMA1=IndGet(handle_SlowMAEnter1,0,SlowMAShift);
            double SlowMA2=IndGet(handle_SlowMAEnter1,0,SlowMAShift+1);
#endif
            if(SlowMA1>SlowMA2)
               return 1;
            else
               return -1;
           }
         break;
         case 4:
           {
#ifdef __MQL4__
            double MACD=iMACD(NULL,IndEnterTF1,MACDFast,MACDSlow,MACDSignal,MACDPrice,MODE_MAIN,MACDShift);
#endif
#ifdef __MQL5__
            double MACD=IndGet(handle_MACDEnter1,0,MACDShift);//Main
#endif
            if(MACD>=0)
               return 1;
            else
               return -1;
           }
         break;
         case 5:
           {
#ifdef __MQL4__
            double ADXPlus=iADX(NULL,IndEnterTF1,ADXPeriod,PRICE_TYPICAL,MODE_PLUSDI,ADXShift);
            double ADXMinus=iADX(NULL,IndEnterTF1,ADXPeriod,PRICE_TYPICAL,MODE_MINUSDI,ADXShift+1);
#endif
#ifdef __MQL5__
            double ADXPlus=IndGet(handle_ADXEnter1,1,ADXShift);
            double ADXMinus=IndGet(handle_ADXEnter1,2,ADXShift+1);
#endif
            if(ADXPlus>=ADXMinus)
               return 1;
            else
               return -1;
           }
         break;
         case 6:
           {
#ifdef __MQL4__
            double SAR=iSAR(NULL,IndEnterTF1,SARStep,SARMaximum,SARShift);
#endif
#ifdef __MQL5__
            double SAR=IndGet(handle_SAREnter1,0,SARShift);
#endif
            if(SAR<=Bid)
               return 1;
            else
               return -1;
           }
         break;
         case 7:
           {
#ifdef __MQL4__
            double OsMA=iOsMA(NULL,IndEnterTF1,OsMAFast,OsMASlow,OsMASignal,OsMAPrice,OsMAShift);
#endif
#ifdef __MQL5__
            double OsMA=IndGet(handle_OsMAEnter1,0,OsMAShift);
#endif
            if(OsMA>=0)
               return 1;
            else
               return -1;
           }
         break;
        }
      if(mode=="Enter2")
        {
         switch(IndNumber)
           {
            case 0:return 0;break;
            case 1:
              {
#ifdef __MQL4__
               double FastMA1=iMA(NULL,IndEnterTF2,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift);
               double FastMA2=iMA(NULL,IndEnterTF2,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift+1);
#endif
#ifdef __MQL5__
               double FastMA1=IndGet(handle_FastMAEnter2,0,FastMAShift);
               double FastMA2=IndGet(handle_FastMAEnter2,0,FastMAShift+1);
#endif
               if(FastMA1>FastMA2)
                  return 1;
               else
                  return -1;
              }
            break;
            case 2:
              {
#ifdef __MQL4__
               double MediumMA1=iMA(NULL,IndEnterTF2,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift);
               double MediumMA2=iMA(NULL,IndEnterTF2,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift+1);
#endif
#ifdef __MQL5__
               double MediumMA1=IndGet(handle_MediumMAEnter2,0,MediumMAShift);
               double MediumMA2=IndGet(handle_MediumMAEnter2,0,MediumMAShift+1);
#endif
               if(MediumMA1>MediumMA2)
                  return 1;
               else
                  return -1;
              }
            break;
            case 3:
              {
#ifdef __MQL4__
               double SlowMA1=iMA(NULL,IndEnterTF2,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift);
               double SlowMA2=iMA(NULL,IndEnterTF2,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift+1);
#endif
#ifdef __MQL5__
               double SlowMA1=IndGet(handle_SlowMAEnter2,0,SlowMAShift);
               double SlowMA2=IndGet(handle_SlowMAEnter2,0,SlowMAShift+1);
#endif
               if(SlowMA1>SlowMA2)
                  return 1;
               else
                  return -1;
              }
            break;
            case 4:
              {
#ifdef __MQL4__
               double MACD=iMACD(NULL,IndEnterTF2,MACDFast,MACDSlow,MACDSignal,MACDPrice,MODE_MAIN,MACDShift);
#endif
#ifdef __MQL5__
               double MACD=IndGet(handle_MACDEnter2,0,MACDShift);//Main
#endif
               if(MACD>=0)
                  return 1;
               else
                  return -1;
              }
            break;
            case 5:
              {
#ifdef __MQL4__
               double ADXPlus=iADX(NULL,IndEnterTF2,ADXPeriod,PRICE_TYPICAL,MODE_PLUSDI,ADXShift);
               double ADXMinus=iADX(NULL,IndEnterTF2,ADXPeriod,PRICE_TYPICAL,MODE_MINUSDI,ADXShift+1);
#endif
#ifdef __MQL5__
               double ADXPlus=IndGet(handle_ADXEnter2,1,ADXShift);
               double ADXMinus=IndGet(handle_ADXEnter2,2,ADXShift+1);
#endif
               if(ADXPlus>=ADXMinus)
                  return 1;
               else
                  return -1;
              }
            break;
            case 6:
              {
#ifdef __MQL4__
               double SAR=iSAR(NULL,IndEnterTF2,SARStep,SARMaximum,SARShift);
#endif
#ifdef __MQL5__
               double SAR=IndGet(handle_SAREnter2,0,SARShift);
#endif
               if(SAR<=Bid)
                  return 1;
               else
                  return -1;
              }
            break;
            case 7:
              {
#ifdef __MQL4__
               double OsMA=iOsMA(NULL,IndEnterTF2,OsMAFast,OsMASlow,OsMASignal,OsMAPrice,OsMAShift);
#endif
#ifdef __MQL5__
               double OsMA=IndGet(handle_OsMAEnter2,0,OsMAShift);
#endif
               if(OsMA>=0)
                  return 1;
               else
                  return -1;
              }
            break;
           }
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void UpdateRegisters()
// Cập nhật bắt buộc tất cả các biến lưu trữ trạng thái giao dịch
// Dùng để đảm bảo EA nhận biết khi lệnh bị từ chối hoặc có lỗi
// Chỉ dành cho chế độ tự động, không cần tối ưu hiệu suất
  {
   BuyOrdersCount=0; // Số lượng lệnh mua
   SellOrdersCount=0; // Số lượng lệnh bán
   OrdersTotalByThisEA=0; // Tổng số lệnh của EA
   TotalLots=0; // Tổng khối lượng lệnh
   TotalTrades=0; // Tổng số giao dịch

   LastBuyTime=0; // Thời gian mua cuối cùng
   LastBuyOrderOpenPrice=0; // Giá mở lệnh mua cuối cùng
   BuyLots=0; // Tổng khối lượng mua
   BuyPrice_x_Lot=0; // Tổng (khối lượng mua * giá mở lệnh mua)
   AverageBuyPrice=0; // Giá mua trung bình
   FirstBuyOrderTime=0; // Thời gian lệnh mua đầu tiên (để kiểm tra hết hạn)

   LastSellTime=0; // Thời gian bán cuối cùng
   LastSellOrderOpenPrice=0; // Giá mở lệnh bán cuối cùng
   SellLots=0; // Tổng khối lượng bán
   SellPrice_x_Lot=0; // Tổng (khối lượng bán * giá mở lệnh bán)
   AverageSellPrice=0; // Giá bán trung bình
   FirstSellOrderTime=0; // Thời gian lệnh bán đầu tiên (để kiểm tra hết hạn)

   for(int i=OrdersTotal()-1; i>=0; i--) // Duyệt qua tất cả các lệnh hiện có
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(i,SELECT_BY_POS)) // Chọn lệnh theo vị trí
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic) // Kiểm tra lệnh của EA
           {
            // Xác nhận đây là lệnh của EA, cập nhật tất cả các biến cần thiết
            if(OrderType()==OP_BUY) // Nếu là lệnh mua
              {
               datetime orderOpenTime=OrderOpenTime(); 
               // Thời gian mở lệnh hiện tại, lưu vào biến để tránh gọi hàm nhiều lần
               BuyTicket[BuyOrdersCount]=OrderTicket(); 
               // Lưu số hiệu lệnh vào mảng
               BuyLot[BuyOrdersCount]=OrderLots(); 
               // Lưu khối lượng lệnh vào mảng, dùng để đóng lệnh
               BuyLots=BuyLots+OrderLots(); 
               // Cộng dồn tổng khối lượng mua
               BuyPrice_x_Lot=BuyPrice_x_Lot+OrderLots()*OrderOpenPrice(); 
               // Cộng dồn (khối lượng mua * giá mở lệnh)
               AverageBuyPrice=BuyPrice_x_Lot/BuyLots; 
               // Tính giá mua trung bình
               BuyOrdersCount++; 
               // Tăng số lượng lệnh mua
               OrdersTotalByThisEA++; 
               // Tăng tổng số lệnh của EA
               TotalLots=TotalLots+OrderLots(); 
               // Tổng khối lượng lệnh
               TotalTrades++; 
               // Tổng số giao dịch
               MinimumTargetBuyTP=AverageBuyPrice==0 ? 0 : NormalizeDouble(AverageBuyPrice+Distance*MinimumTP,Digits); 
               // Mục tiêu chốt lời cho lệnh mua
               LastBuyTime=MathMax(LastBuyTime,orderOpenTime); 
               // Thời gian mua cuối cùng
               if(LastBuyOrderOpenPrice>0) 
                  // Nếu đã có giá mua trước đó
                  LastBuyOrderOpenPrice=MathMin(LastBuyOrderOpenPrice,OrderOpenPrice()); 
                  // Giá mở lệnh mua thấp nhất (để xử lý chiến lược Martingale)
               else
                  LastBuyOrderOpenPrice=OrderOpenPrice(); 
                  // Nếu chưa có giá, đặt giá hiện tại
               if(FirstBuyOrderTime>0) 
                  // Nếu đã có thời gian lệnh mua đầu tiên
                  FirstBuyOrderTime=MathMin(FirstBuyOrderTime,orderOpenTime); 
                  // Cập nhật thời gian lệnh mua đầu tiên sớm nhất
               else
                  FirstBuyOrderTime=orderOpenTime; 
                  // Nếu chưa có, đặt thời gian hiện tại
              }
            if(OrderType()==OP_SELL) // Nếu là lệnh bán
              {
               datetime orderOpenTime=OrderOpenTime(); 
               // Thời gian mở lệnh hiện tại, lưu vào biến để tránh gọi hàm nhiều lần
               SellTicket[SellOrdersCount]=OrderTicket(); 
               // Lưu số hiệu lệnh vào mảng
               SellLot[SellOrdersCount]=OrderLots(); 
               // Lưu khối lượng lệnh vào mảng, dùng để đóng lệnh
               SellLots=SellLots+OrderLots(); 
               // Cộng dồn tổng khối lượng bán
               SellPrice_x_Lot=SellPrice_x_Lot+OrderLots()*OrderOpenPrice(); 
               // Cộng dồn (khối lượng bán * giá mở lệnh)
               AverageSellPrice=SellPrice_x_Lot/SellLots; 
               // Tính giá bán trung bình
               SellOrdersCount++; 
               // Tăng số lượng lệnh bán
               OrdersTotalByThisEA++; 
               // Tăng tổng số lệnh của EA
               TotalLots=TotalLots+OrderLots(); 
               // Tổng khối lượng lệnh
               TotalTrades++; 
               // Tổng số giao dịch
               MinimumTargetSellTP=AverageSellPrice==0 ? 0 : NormalizeDouble(AverageSellPrice-Distance*MinimumTP,Digits); 
               // Mục tiêu chốt lời cho lệnh bán
               LastSellTime=MathMax(LastSellTime,orderOpenTime); 
               // Thời gian bán cuối cùng
               if(LastSellOrderOpenPrice>0) 
                  // Nếu đã có giá bán trước đó
                  LastSellOrderOpenPrice=MathMax(LastSellOrderOpenPrice,OrderOpenPrice()); 
                  // Giá mở lệnh bán cao nhất (để xử lý chiến lược Martingale)
               else
                  LastSellOrderOpenPrice=OrderOpenPrice(); 
                  // Nếu chưa có giá, đặt giá hiện tại
               if(FirstSellOrderTime>0) 
                  // Nếu đã có thời gian lệnh bán đầu tiên
                  FirstSellOrderTime=MathMin(FirstSellOrderTime,orderOpenTime); 
                  // Cập nhật thời gian lệnh bán đầu tiên sớm nhất
               else
                  FirstSellOrderTime=orderOpenTime; 
                  // Nếu chưa có, đặt thời gian hiện tại
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DueCut()
//到期砍仓
  {
   if(OrdersTotalByThisEA>0)
     {
      if(BuyOrdersCount>0)
         if(Time_Current-FirstBuyOrderTime>3600*24*DueDays)
            //多单超时
            CloseBuyOrders();
      if(SellOrdersCount>0)
         if(Time_Current-FirstSellOrderTime>3600*24*DueDays)
            //多单超时
            CloseSellOrders();
     }
   return;
  }
//+------------------------------------------------------------------+
bool isNewsRelease()
  {
   NotInNewsTime=false;
//默认标记为有数据 禁止开仓 仅平仓
   if(
      (Time_Current>=D'2015.01.14' && Time_Current<=D'2015.01.16')//瑞郎黑天鹅 所有货币禁止
      || ((Time_Current>=D'2014.12.30' && Time_Current<=D'2015.02.16') && StringFind(Symbol(),"CHF",0)>-1)//瑞郎黑天鹅瑞郎特别强化过滤
      //|| ((Time_Current>=D'2014.07.20' && Time_Current<=D'2015.03.22') && StringFind(Symbol(),"USD",0)>-1)//美元大牛市
      //|| ((Time_Current>=D'2012.12.09' && Time_Current<=D'2013.04.21') && StringFind(Symbol(),"JPY",0)>-1)//日元大熊市1 日本政府打压日元
      //|| ((Time_Current>=D'2014.10.31' && Time_Current<=D'2014.11.24') && StringFind(Symbol(),"JPY",0)>-1)//日元大熊市2 黑田东彦意外动作
      || (Time_Current>=D'2016.06.22' && Time_Current<=D'2016.06.28')//退欧 
      || ((Time_Current>=D'2016.10.06' && Time_Current<=D'2016.10.10') && StringFind(Symbol(),"GBP",0)>-1)//英镑黑天鹅
      || (Time_Current>=D'2016.11.04' && Time_Current<=D'2016.11.10')//美国大选
      )
      //禁止开仓时间范围内
     {
      CloseBuyOrders();
      CloseSellOrders();
      //强制砍仓
      return true;
     }
   else
     {
      NotInNewsTime=true;
      //不在需要砍仓的时间范围
      return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
void StatsClose(int orderTicket,int Number,double Max,double Min)
  {
   if(RecordCSV)
     {
      if(OrderSelect(orderTicket,SELECT_BY_TICKET,MODE_TRADES))
        {
         TotalKickback=TotalKickback+LotKickback*OrderLots();
         //总佣金=前面的统计+每手佣金*订单手数
         string orderType="NULL";
         //订单类型文字 识别不出就是NULL
         if(OrderType()==OP_BUY) {orderType="多";}
         if(OrderType()==OP_SELL) {orderType="空";}
         //订单类型文字
         FileSeek(StatCloseHandle,0,SEEK_END);
         //调到最后一行 init已经初始化过句柄 不再重新初始化 防止降速
         FileWrite(StatCloseHandle,
                   OrderTicket(),
                   //订单编号
                   TimeToString(OrderOpenTime(),TIME_DATE|TIME_MINUTES),
                   //开仓时间
                   TimeToString(Time_Current),
                   //平仓时间
                   OrderSymbol(),
                   //货币
                   orderType,
                   //多空文字
                   NormalizeDouble(OrderLots(),2),
                   //手数
                   NormalizeDouble(OrderStopLoss(),Digits),
                   //止损价格
                   NormalizeDouble(OrderTakeProfit(),Digits),
                   //止盈价格
                   NormalizeDouble(OrderOpenPrice(),Digits),
                   //开仓价格
                   NormalizeDouble(OrderClosePrice(),Digits),
                   //平仓价格
                   NormalizeDouble(OrderCommission(),Digits),
                   //手续费
                   NormalizeDouble(OrderSwap(),3),
                   //过夜利息
                   NormalizeDouble((Time_Current-OrderOpenTime())/3600,2),
                   //持仓时长
                   NormalizeDouble(OrderProfit()/OrderLots(),2),
                   //考虑点值后的点数
                   NormalizeDouble(AccountProfit(),2),
                   //账户盈亏
                   NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap()-OrderLots()*ExtraCommission*ExtraCommissionMultiply,2),
                   //平仓盈利(含费用)
                   NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap()+LotKickback*OrderLots(),2),
                   //含返佣盈利(含费用)
                   NormalizeDouble(LotKickback*OrderLots(),2),
                   //返佣
                   NormalizeDouble(TotalKickback,2),
                   //累计返佣
                   NormalizeDouble(AccountMargin(),2),
                   //已用保证金
                   NormalizeDouble(AccountBalance()-initBalance,2),
                   //余额变化 减去初始余额 下同
                   NormalizeDouble(AccountEquity()-initBalance,2),
                   //净值变化
                   NormalizeDouble(AccountEquity()-initBalance+TotalKickback,2),
                   //含返佣净值
                   NormalizeDouble(AccountBalance()-initBalance+TotalKickback,2),
                   //含返佣余额
                   MaxFloatLoss,
                   //历史最大浮亏
                   Number,Max,Min,
                   NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap()-OrderLots()*ExtraCommission*ExtraCommissionMultiply,2)
                   //平仓盈利(含费用)
                   //,"=SUM(F:F),=SUM(L:L),=SUM(P:P),=MAX(S:S),=SUM(Q:Q)"
                   //Excel计算用附加
                   );
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL5__ 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IndGet(int handle,const int index,int shift)
  {
   static double Ind[1];
   if(CopyBuffer(handle,index,shift,1,Ind)<0)
     {
      PrintFormat("Failed to copy data from the indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0);
     }
   return(Ind[0]);
  }
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZuluTrade()
  {
   for(int i=BuyOrdersCount-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
#ifdef __MQL5__
      if(PositionSelectByTicket(BuyTicket[i]))
        {
         BuyMin[i]=MathMin(BuyMin[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
         BuyMax[i]=MathMax(BuyMax[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
        }
#endif
#ifdef __MQL4__
      if(OrderSelect(BuyTicket[i],SELECT_BY_TICKET))
        {
         BuyMin[i]=MathMin(BuyMin[i],OrderProfit()+OrderCommission()+OrderSwap());
         BuyMax[i]=MathMax(BuyMax[i],OrderProfit()+OrderCommission()+OrderSwap());
        }
#endif

     }
   for(int i=SellOrdersCount-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
#ifdef __MQL5__
      if(PositionSelectByTicket(SellTicket[i]))
        {
         SellMin[i]=MathMin(SellMin[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
         SellMax[i]=MathMax(SellMax[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
        }
#endif
#ifdef __MQL4__
      if(OrderSelect(SellTicket[i],SELECT_BY_TICKET))
        {
         SellMin[i]=MathMin(SellMin[i],OrderProfit()+OrderCommission()+OrderSwap());
         SellMax[i]=MathMax(SellMax[i],OrderProfit()+OrderCommission()+OrderSwap());
        }
#endif
     }
  }
//+------------------------------------------------------------------+
