{
  IceTabSet v1.2.0
  Developed by Norbert Mereg (mereg.norbert@gmail.com)
    (Thanks for Stefan Ascher (TMDTabSet))

  Web: https://sourceforge.net/projects/icetabset/

  Description:
    This component is a 'Google Chrome style' TTabSet component for Delphi.

  Required:
    - Delphi GDI+ API (http://www.progdigy.com/files/gdiplus.zip)

  Features:
    - Show icon in tab items
    - Gradient color tab and component background
    - Close icon in tab
    - Rounded tab edges
    - Scrollable, if have more item
    - TabItems has a Modified property
    - Dragging of tabs
    - New tab button


  History:
    v1.2.0  2011.07.08:
      - reworked scroller class
      - no flickering, Double buffered paint method

    v1.1.2  2010.11.25:
      - New feature: added dragging of tabs (Thanks for Omar Reis)
      - Fixed: changed some hard coded wast of space in the end of the texts (Thanks for Omar Reis)

    v1.1.0  2010.10.18:
      - New feature: 'New tab' button with event
      - New feature: Tab auto-width property
      - New feature: Double click event
      - Fixed: Make D7 compatible (thx for Nilson)
      - Fixed: MaxTabWidth long-text problem

    v1.0.1  2010.07.14:
      - Bug fixed: Icon draw problem, when a foreground window goes to hide.


    v1.0.0  2010.06.14 - First release.
}

unit IceTabSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ImgList, GDIPAPI, GDIPOBJ;

type
  TIceTab = class(TCollectionItem)
  private
    fCaption: TCaption;
    fSelected: boolean;
    fData: TObject;
    fModified: boolean;
    fImageIndex: TImageIndex;
    FTag: integer;
    procedure SetSelected(Value: boolean);
    procedure SetModified(Value: boolean);
    procedure DoChange;
    procedure SetCaption(Value: TCaption);
    procedure SetImageIndex(Value: TImageIndex);
    procedure SetTag(const Value: integer);
  protected
    fStartPos: integer;
    fSize: integer;
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property Data: TObject read fData write fData;
  published
    property Caption: TCaption read fCaption write SetCaption;
    property Selected: boolean read fSelected write SetSelected;
    property Modified: boolean read fmodified write SetModified;
    property Tag: integer read FTag write SetTag default 0;
    property ImageIndex: TImageIndex read fImageIndex write SetImageIndex default -1;
  end;

  TIceTabList = class(TOwnedCollection)
  protected
    procedure DoSelected(ATab: TIceTab; ASelected: boolean); dynamic;
    procedure DoChanged(ATab: TIceTab); dynamic;
    procedure SetItem(Index: Integer; Value: TIceTab);
    function GetItem(Index: Integer): TIceTab;
  public
    function IndexOf(ATab: TIceTab): integer;
    property Items[Index: Integer]: TIceTab read GetItem write SetItem; default;
  end;

  TScrollButton = (sbNone, sbLeft, sbRight);

  TScrollButtonClickEvent = procedure(Sender: TObject; const AButton: TScrollButton) of object;

(*  TIceTabScroller = class(TCustomControl)
  private
    fOnClick: TScrollButtonClickEvent;
    fCurrent: TScrollButton;
    fDown: boolean;
    fPressed: boolean;
    fWidth: integer;
    fHeight: integer;
    fPosition: integer;
    fMin: integer;
    fMax: integer;
    fChange: integer;
    fDownColor: TColor;
    fDownBorder: TColor;
    FArrowColor: TColor;
    function CanScrollLeft: Boolean;
    function CanScrollRight: Boolean;
    procedure DoMouseDown(const X: Integer);
    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure SetPosition(Value: Integer);
    procedure SetDownColor(Value: TColor);
    procedure SetDownBorder(Value: TColor);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure DrawRightArrow(Canvas: TCanvas; X, Y: integer;
      Button: TScrollButton; State: boolean);
    procedure DrawLeftArrow(Canvas: TCanvas; X, Y: integer;
      Button: TScrollButton; State: boolean);
    procedure SetArrowColor(const Value: TColor);
  protected
    procedure Paint; override;
    procedure DoOnClick(const AButton: TScrollButton); dynamic;
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DownColor: TColor read fDownColor write SetDownColor default DEF_DOWNCOLOR;
    property DownBorder: TColor read fDownBorder write SetDownBorder default DEF_DOWNBORDER;
    property ArrowColor: TColor read FArrowColor write SetArrowColor;

    property Min: Longint read fMin write SetMin default 0;
    property Max: Longint read fMax write SetMax default 0;
    property Position: Longint read fPosition write SetPosition default 0;
    property Change: Integer read fChange write fChange default 1;
    property OnClick: TScrollButtonClickEvent read fOnClick write fOnClick;
  end;
*)
  TBeforeShowPopupMenuEvent = procedure(Sender: TObject; ATab: TIceTab; MousePos: TPoint) of object;

  TTabSelectedEvent = procedure(Sender: TObject; ATab: TIceTab; ASelected: boolean) of object;
  TTabCloseEvent = procedure(Sender: TObject; ATab: TIceTab) of object;

  TIceTabSet = class(TCustomControl)
  private
    fTabs: TIceTabList;
    //fScroller: TIceTabScroller;
    fTabBorderColor: TColor;
    fListMenu: TPopupMenu;
    fFont: TFont;
    fSelectedFont: TFont;
    fFirstIndex: integer;
    fVisibleTabs: Integer;
    fTabIndex: integer;
    fMaxTabWidth: integer;
    fImages: TCustomImageList;
    fMaintainMenu: boolean;
    fOnScrollButtonClick: TScrollButtonClickEvent;
    fOnTabSelected: TTabSelectedEvent;
    FTabHeight: integer;
    FEdgeWidth: integer;
    FCloseTab: boolean;
    FTabStopColor: TColor;
    FTabStartColor: TColor;
    FSelectedTabStopColor: TColor;
    FSelectedTabStartColor: TColor;
    FModifiedTabStopColor: TColor;
    FModifiedTabStartColor: TColor;
    FTabCloseColor: TColor;
    FModifiedFont: TFont;
    FBackgroundStopColor: TColor;
    FBackgroundStartColor: TColor;
    FOnBeforeShowPopupMenu: TBeforeShowPopupMenuEvent;
    FOnTabClose: TTabCloseEvent;
    FHighlightTabClose: TIceTab;
    FOnDblClick: TTabCloseEvent;
    FShowNewTab: boolean;
    FAutoTabWidth: boolean;
    FNewButtonArea: TRect;
    FHighlightNewButton: boolean;
    FOnNewButtonClick: TNotifyEvent;
    // Om: tab drag functionality
    fCanDragTabs:boolean;
    fIxTabStartDrag:integer;      // move tab "from" index
    fIxTabEndDrag:Integer;        // move tab "to" index
    fTabDragPointerVisible:boolean;
    // /tab drag

    // Scroll variables
    fScrollWidth: integer;
    fScrollHeight: integer;
    fScrollLeft: integer;
    fScrollTop: integer;
    fScrollPushed: TScrollButton;
    FArrowColor: TColor;
    FArrowHighlightColor: TColor;

    procedure ScrollClick(const AButton: TScrollButton);
    function GetTabHeight: integer;
    procedure SetTab(NewTab: TIceTab);
    procedure SetTabIndex(Value: Integer); //overload;
    //procedure SetTabIndex(NewTab: TIceTab); overload;
    function CalcTabPositions(Start, Stop: Integer; Canvas: TCanvas;
      JumpTab: TIceTab): Integer;

    function GetSelected: TIceTab;
    procedure SetSelected(Value: TIceTab);
    procedure SetFont(Value: TFont);
    procedure SetSelectedFont(Value: TFont);
    procedure SetTabBorderColor(Value: TColor);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure SetMaxTabWidth(Value: integer);
    procedure SetTabHeight(const Value: integer);
    function GetGDIPFont(Canvas: TCanvas; Font: TFont): TGPFont;
    function GetTextSize(Canvas: TCanvas; Font: TGPFont; Text: string): TSize;
    procedure SetEdgeWidth(const Value: integer);
    procedure SetCloseTab(const Value: boolean);
    procedure SetTabStartColor(const Value: TColor);
    procedure SetTabStopColor(const Value: TColor);
    procedure SetSelectedTabStartColor(const Value: TColor);
    procedure SetSelectedTabStopColor(const Value: TColor);
    procedure SetModifiedTabStartColor(const Value: TColor);
    procedure SetModifiedTabStopColor(const Value: TColor);
    procedure SetTabCloseColor(const Value: TColor);
    procedure SetModifiedFont(const Value: TFont);
    procedure SetBackgroundStartColor(const Value: TColor);
    procedure SetBackgroundStopColor(const Value: TColor);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetOnBeforeShowPopupMenu(const Value: TBeforeShowPopupMenuEvent);
    function IsInCloseButton(ATab: TIceTab; X, Y: integer): boolean;
    procedure SetOnTabClose(const Value: TTabCloseEvent);
    procedure SetHighlightTabClose(const Value: TIceTab);
    procedure ClearSelection;
    procedure InnerDraw(Canvas: TCanvas; TabRect: TRect; Item: TIceTab);
    procedure SetArrowColor(const Value: TColor);
    procedure SetOnDblClick(const Value: TTabCloseEvent);
    procedure SetShowNewTab(const Value: boolean);
    procedure SetAutoTabWidth(const Value: boolean);
    procedure DrawNewButton(Canvas: TCanvas);
    procedure SetHighlightNewButton(const Value: boolean);
    procedure SetOnNewButtonClick(const Value: TNotifyEvent);
    procedure DrawDragTabPointer(aTabIndex: integer);
    procedure DrawScroll(Canvas: TCanvas);
    procedure DrawScrollLeftArrow(Canvas: TCanvas; X, Y: integer;
      Button: TScrollButton; State: boolean);
    procedure DrawScrollRightArrow(Canvas: TCanvas; X, Y: integer;
      Button: TScrollButton; State: boolean);
    procedure SetArrowHighlightColor(const Value: TColor); //Om:
  protected
    property HighlightTabClose: TIceTab read FHighlightTabClose write SetHighlightTabClose;
    property HighlightNewButton: boolean read FHighlightNewButton write SetHighlightNewButton;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;

    procedure ShowRightPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);

    procedure DoOnScrollButtonClick(const AButton: TScrollButton); dynamic;
    procedure TabSelected(ATab: TIceTab; ASelected: boolean); dynamic;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    procedure DragOver( Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean ); override; //Om:
    procedure DragDrop( Source: TObject; X, Y: Integer ); override;                                         //Om:
    procedure DoTabEndDrag; //Om:
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoDoubleClick(ATab: TIceTab);
    function GetButtonRect(const AButton: TScrollButton): TRect;
    function GetItemFromPos(X, Y: integer): TIceTab;
    procedure LookThisTab(ATab: TIceTab);

    function AddTab(const ACaption: string; const ImageIndex: integer = -1; const Data: TObject = nil): TIceTab;
    function RemoveTab(ATab: TIceTab): integer;
    procedure SelectNext(ANext: boolean);
    function IndexOfTabData(Data: TObject): integer;

    property Selected: TIceTab read GetSelected write SetSelected;
  published
    property Align;
    property Anchors;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Visible;

    property Font: TFont read fFont write SetFont;
    property SelectedFont: TFont read fSelectedFont write SetSelectedFont;
    property ModifiedFont: TFont read FModifiedFont write SetModifiedFont;
    property Tabs: TIceTabList read fTabs write fTabs;
    property TabIndex: integer read fTabIndex write SetTabIndex default -1;
    property TabBorderColor: TColor read fTabBorderColor write SetTabBorderColor default $00706453;
    property ListMenu: TPopupMenu read fListMenu write fListMenu;
    property Images: TCustomImageList read fImages write SetImages;
    property MaintainMenu: boolean read fMaintainMenu write fMaintainMenu;
    property MaxTabWidth: integer read fMaxTabWidth write SetMaxTabWidth default 0;
    property TabHeight: integer read FTabHeight write SetTabHeight default 24;
    property EdgeWidth: integer read FEdgeWidth write SetEdgeWidth default 20;
    property CloseTab: boolean read FCloseTab write SetCloseTab default true;
    property ShowNewTab: boolean read FShowNewTab write SetShowNewTab default false;
    property TabCloseColor: TColor read FTabCloseColor write SetTabCloseColor default $00B8AFA9;
    property ArrowColor: TColor read FArrowColor write SetArrowColor default clBlack;
    property ArrowHighlightColor: TColor read FArrowHighlightColor write SetArrowHighlightColor default $00EAE6E1;
    property AutoTabWidth: boolean read FAutoTabWidth write SetAutoTabWidth default true;

    property TabStartColor: TColor read FTabStartColor write SetTabStartColor default $00A19078;
    property TabStopColor: TColor read FTabStopColor write SetTabStopColor default $00A19078;

    property SelectedTabStartColor: TColor read FSelectedTabStartColor write SetSelectedTabStartColor default $00FBF9F7;
    property SelectedTabStopColor: TColor read FSelectedTabStopColor write SetSelectedTabStopColor default $00EAE6E1;

    property ModifiedTabStartColor: TColor read FModifiedTabStartColor write SetModifiedTabStartColor;
    property ModifiedTabStopColor: TColor read FModifiedTabStopColor write SetModifiedTabStopColor;

    property BackgroundStartColor: TColor read FBackgroundStartColor write SetBackgroundStartColor default $00C8BDB0;
    property BackgroundStopColor: TColor read FBackgroundStopColor write SetBackgroundStopColor default $00C8BDB0;

    property CanDragTabs:boolean read fCanDragTabs write fCanDragTabs;  //Om: tabs can be moved by dragging

    property OnClick;
    property OnDblClick: TTabCloseEvent read FOnDblClick write SetOnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;

    property OnScrollButtonClick: TScrollButtonClickEvent read fOnScrollButtonClick write fOnScrollButtonClick;
    property OnTabSelected: TTabSelectedEvent read fOnTabSelected write fOnTabSelected;
    property OnBeforeShowPopupMenu: TBeforeShowPopupMenuEvent read FOnBeforeShowPopupMenu write SetOnBeforeShowPopupMenu;
    property OnTabClose: TTabCloseEvent read FOnTabClose write SetOnTabClose;
    property OnNewButtonClick: TNotifyEvent read FOnNewButtonClick write SetOnNewButtonClick;
  end;

procedure Register;

implementation

uses
  CommCtrl, Consts, Math;

const
  BMP_SIZE = 12;
  BTN_MARGIN = 2;
  BTN_SIZE = BMP_SIZE + BTN_MARGIN * 2;

procedure Register;
begin
  RegisterComponents('IcePackage', [TIceTabSet]);
end;

function MakeGDIPColor(C: TColor): Cardinal;
var
  tmpRGB : TColorRef;
begin
  tmpRGB := ColorToRGB(C);
  result := ((DWORD(GetBValue(tmpRGB)) shl  BlueShift) or
             (DWORD(GetGValue(tmpRGB)) shl GreenShift) or
             (DWORD(GetRValue(tmpRGB)) shl   RedShift) or
             (DWORD(255) shl AlphaShift));
end;

{ TIceTabScroller }
(*
constructor TIceTabScroller.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque];
  fWidth := BTN_SIZE * 2 + 1;
  fHeight := BTN_SIZE;
  fMin := 0;
  fMax := 0;
  fPosition := 0;
  fChange := 1;
  fArrowColor := clBlack;
  fDownColor := DEF_DOWNCOLOR;
  fDownBorder := DEF_DOWNBORDER;
end;

destructor TIceTabScroller.Destroy;
begin
  inherited;
end;

procedure TIceTabScroller.Paint;
const
  DWN: array[Boolean] of Integer = (0, 4);

var
  ParRect: TRect;
  P: TPoint;
  bmp: TBitmap;
begin
  if (Parent <> nil) and Parent.HandleAllocated then
    InvalidateRect(Parent.Handle, @Rect, True);

  with Canvas do
  begin
    // Draw parent background
    P := ClientToParent(ClientRect.TopLeft);
    ParRect := Rect(P, Point(P.X + ClientRect.Right - ClientRect.Left, P.Y + ClientRect.Bottom - ClientRect.Top));
    Canvas.CopyRect(ClientRect, TIceTabSet(Parent).Canvas, ParRect);

    // Left
    if (fCurrent = sbLeft) and fDown then
    begin
      Brush.Color := fDownColor;
      Canvas.Rectangle(0, 0, BTN_SIZE, BTN_SIZE);
    end;
    if CanScrollLeft then
      DrawLeftArrow(Canvas, BTN_MARGIN, BTN_MARGIN, sbLeft, CanScrollLeft);

    // Right
    if (fCurrent = sbRight) and fDown then
    begin
      Brush.Color := fDownColor;
      Canvas.Rectangle(BTN_SIZE, 0, BTN_SIZE * 2, BTN_SIZE);
    end;
    if CanScrollRight then
      DrawRightArrow(Canvas, BTN_SIZE + BTN_MARGIN, BTN_MARGIN, sbRight, CanScrollRight);
  end;
end;

procedure TIceTabScroller.DrawRightArrow(Canvas: TCanvas; X, Y: integer; Button: TScrollButton; State: boolean);
var
  graphics: TGPGraphics;
  path: TGPGraphicsPath;
  brush: TGPSolidBrush;
  innerRect: TRect;
begin
  graphics := TGPGraphics.Create(Canvas.Handle);
  graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  path := TGPGraphicsPath.Create();
  innerRect := Rect(X + 2, Y + 2, X + 2 + 6, Y + 2 + 8);
  path.AddLine(innerRect.Left, innerRect.Top, InnerRect.Right, InnerRect.Top + 4);
  path.AddLine(innerRect.Right, innerRect.Top + 4, InnerRect.Left, InnerRect.Bottom);
  path.AddLine(innerRect.Left, innerRect.Bottom, InnerRect.Left, InnerRect.Top);

  brush:= TGPSolidBrush.Create(MakeGDIPColor(clBlack));
  graphics.FillPath(brush, path);

  brush.Free;
  path.Free;
  graphics.Free;
end;

procedure TIceTabScroller.DrawLeftArrow(Canvas: TCanvas; X, Y: integer; Button: TScrollButton; State: boolean);
var
  graphics: TGPGraphics;
  path: TGPGraphicsPath;
  brush: TGPSolidBrush;
  innerRect: TRect;
begin
  graphics := TGPGraphics.Create(Canvas.Handle);
  graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  path := TGPGraphicsPath.Create();
  innerRect := Rect(X + 3, Y + 2, X + 3 + 6, Y + 2 + 8);
  path.AddLine(innerRect.Right, innerRect.Top, InnerRect.Left, InnerRect.Top + 4);
  path.AddLine(innerRect.Left, innerRect.Top + 4, InnerRect.Right, InnerRect.Bottom);
  path.AddLine(innerRect.Right, innerRect.Bottom, InnerRect.Right, InnerRect.Top);

  brush:= TGPSolidBrush.Create(MakeGDIPColor(fArrowColor));
  graphics.FillPath(brush, path);

  brush.Free;
  path.Free;
  graphics.Free;
end;


procedure TIceTabScroller.DoOnClick(const AButton: TScrollButton);
begin
  if Assigned(fOnClick) then
    fOnClick(Self, AButton);
end;

function TIceTabScroller.CanScrollLeft: Boolean;
begin
  Result := fPosition > fMin;
end;

function TIceTabScroller.CanScrollRight: Boolean;
begin
  Result := fPosition < fMax;
end;

procedure TIceTabScroller.DoMouseDown(const X: Integer);
begin
  fCurrent := TScrollButton(X div BTN_SIZE);
  case fCurrent of
    sbLeft: if not CanScrollLeft then Exit;
    sbRight: if not CanScrollRight then Exit;
  end;
  fPressed := True;
  fDown := True;
  Invalidate;
  SetCapture(Handle);
end;

procedure TIceTabScroller.WMLButtonDown(var Message: TWMLButtonDown);
begin
  DoMouseDown(Message.XPos);
end;

procedure TIceTabScroller.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  DoMouseDown(Message.XPos);
end;

procedure TIceTabScroller.WMMouseMove(var Message: TWMMouseMove);
var
  P: TPoint;
  R: TRect;
begin
  if fPressed then begin
    P := Point(Message.XPos, Message.YPos);
    R := Rect(0, 0, BTN_SIZE * Ord(fCurrent), fHeight);
    if PtInRect(R, P) <> fDown then begin
      fDown := not fDown;
      Invalidate;
    end;
  end;
end;

procedure TIceTabScroller.WMLButtonUp(var Message: TWMLButtonUp);
var
  NewPos: Longint;
begin
  ReleaseCapture;
  fPressed := False;

  if fDown then begin
    fDown := False;
    NewPos := Position;
    case fCurrent of
      sbLeft: Dec(NewPos, fChange);
      sbRight: Inc(NewPos, fChange);
    end;
    Position := NewPos;
    DoOnClick(fCurrent);
  end;
end;

procedure TIceTabScroller.WMSize(var Message: TWMSize);
begin
  inherited;
  Width := fWidth - 1;
  Height := fHeight;
end;

procedure TIceTabScroller.SetMin(Value: Integer);
begin
  if Value < fMax then
    fMin := Value;
end;

procedure TIceTabScroller.SetMax(Value: Integer);
begin
  if Value >= fMin then
    fMax := Value;
end;

procedure TIceTabScroller.SetPosition(Value: Integer);
begin
  if Value <> fPosition then begin
    if Value < Min then
      Value := Min;
    if Value > Max then
      Value := Max;
    fPosition := Value;
  end;
  Invalidate;
end;

procedure TIceTabScroller.SetDownColor(Value: TColor);
begin
  if fDownColor <> Value then begin
    fDownColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabScroller.SetArrowColor(const Value: TColor);
begin
  if FArrowColor <> Value then begin
    FArrowColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabScroller.SetDownBorder(Value: TColor);
begin
  if fDownBorder <> Value then begin
    fDownBorder := Value;
    Invalidate;
  end;
end;   *)

{ TIceTab }

constructor TIceTab.Create(Collection: TCollection);
begin
  inherited;
  fImageIndex := -1;
end;

destructor TIceTab.Destroy;
begin
  inherited;
end;

procedure TIceTab.SetModified(Value: boolean);
begin
  if fModified <> Value then begin
    fModified := Value;
    DoChange;
  end;
end;

procedure TIceTab.SetSelected(Value: boolean);
var
  i: integer;
begin
  if fSelected <> Value then
  begin
    fSelected := Value;
    if fSelected then
    begin
      with (GetOwner as TIceTabList) do
      begin
        for i := 0 to Count - 1 do
        begin
          // Only one can be selected
          if (Items[i] <> Self) and (Items[i].Selected) then
          begin
            Items[i].Selected := false;
          end;
        end;
      end;
    end;
    (Collection as TIceTabList).DoSelected(Self, fSelected);
  end;
end;

procedure TIceTab.SetTag(const Value: integer);
begin
  FTag := Value;
end;

function TIceTab.GetDisplayName: string;
begin
  if fCaption <> '' then
    Result := fCaption
  else
    Result := inherited GetDisplayName;
end;

procedure TIceTab.DoChange;
begin
  (Collection as TIceTabList).DoChanged(Self)
end;

procedure TIceTab.SetCaption(Value: TCaption);
begin
  if fCaption <> Value then begin
    fCaption := Value;
    DoChange;
  end;
end;

procedure TIceTab.SetImageIndex(Value: TImageIndex);
begin
  if fImageIndex <> Value then begin
    fImageIndex := Value;
    DoChange;
  end;
end;

{ TIceTabList }

procedure TIceTabList.DoSelected(ATab: TIceTab; ASelected: boolean);
begin
  (GetOwner as TIceTabSet).TabSelected(ATab, ASelected);
end;

procedure TIceTabList.DoChanged(ATab: TIceTab);
begin
  (GetOwner as TIceTabSet).Invalidate;
end;

procedure TIceTabList.SetItem(Index: Integer; Value: TIceTab);
begin
  inherited SetItem(Index, Value);
end;

function TIceTabList.GetItem(Index: Integer): TIceTab;
begin
  Result := inherited GetItem(Index) as TIceTab;
end;

function TIceTabList.IndexOf(ATab: TIceTab): integer;
var
  i, c: integer;
begin
  c := Count;
  for i := 0 to c - 1 do
    if Items[i] = ATab then begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

{ TMDTabSet }

constructor TIceTabSet.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csCaptureMouse, csDoubleClicks, csOpaque];
  Width := 185;
  Height := 30;
  fTabHeight := 24;
  fEdgeWidth := 20;
  fCloseTab := true;
  fShowNewTab := false;
  FHighlightNewButton := false;
  AutoTabWidth := true;
  Align := alTop;
  FHighlightTabClose := nil;

  OnContextPopup := ShowRightPopup;

  fTabs := TIceTabList.Create(Self, TIceTab);
  fFont := TFont.Create;
  fFont.Color := clWhite;
  fModifiedFont := TFont.Create;
  fModifiedFont.Color := $00B3B3FF;
  fSelectedFont := TFont.Create;
  fSelectedFont.Color := clBlack;
  fTabBorderColor := $00706453;
  fTabCloseColor := $00B8AFA9;
  FArrowColor := clBlack;
  fArrowHighlightColor := $00EAE6E1;

  FBackgroundStartColor := $00C8BDB0;
  FBackgroundStopColor := $00C8BDB0;

  fTabStartColor := $00A19078;
  fTabStopColor := $00A19078;

  FSelectedTabStartColor := $00FBF9F7;
  FSelectedTabStopColor := $00EAE6E1;

  FModifiedTabStartColor := $00A19078;
  FModifiedTabStopColor := $00A19078;

  fTabIndex := -1;

  fScrollPushed := sbNone;
  fScrollWidth := BTN_SIZE * 2 + 1;
  fScrollHeight := BTN_SIZE;
  fScrollTop := (Height div 2) - (fScrollHeight div 2);
  fScrollLeft := Width - fScrollWidth - 1;

  fCanDragTabs     := true;          //Om: default=allow tab dragging
  fIxTabStartDrag  := -1;            //Om: -1=none
  fIxTabEndDrag    := -1;            //Om: -1=none
  fTabDragPointerVisible := false;   //Om: drag tab pointer is a little triangle
end;

destructor TIceTabSet.Destroy;
begin
  fTabs.Free;
  fFont.Free;
  fSelectedFont.Free;
  fModifiedFont.Free;
  inherited;
end;

procedure TIceTabSet.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do begin
    style := style and not (CS_VREDRAW or CS_HREDRAW);
  end;
end;

procedure TIceTabSet.ScrollClick(const AButton: TScrollButton);
begin
  case AButton of
    sbLeft: if fFirstIndex > 0 then fFirstIndex := fFirstIndex - 1;
    sbRight: if fFirstIndex < fTabs.Count - fVisibleTabs then fFirstIndex := fFirstIndex + 1;
  end;
  DoOnScrollButtonClick(AButton);
end;

procedure TIceTabSet.DoDoubleClick(ATab: TIceTab);
begin
  if Assigned(OnDblClick) then
    OnDblClick(Self, ATab);
end;

procedure TIceTabSet.DoOnScrollButtonClick(const AButton: TScrollButton);
begin
  if Assigned(fOnScrollButtonClick) then
    fOnScrollButtonClick(Self, AButton);
end;

function TIceTabSet.CalcTabPositions(Start, Stop: Integer; Canvas: TCanvas;
  JumpTab: TIceTab): Integer;
var
  Index: Integer;
  W: Integer;
  tw: integer;
  Tab: TIceTab;
  actFont, prevFont: TGPFont;
  MaxTabWidth, OrigStart: integer;
  reqWidth: integer;
  bJumped: boolean;

  procedure ClearTabPositions;
  var
    I: Integer;
  begin
    for I := 0 to fTabs.Count - 1 do
    begin
      fTabs[I].fStartPos := 0;
      fTabs[I].fSize := 0;
    end;
  end;

begin
  bJumped := false;
  ClearTabPositions;

  if Assigned(JumpTab) and (JumpTab.Index < fFirstIndex) then
    fFirstIndex := JumpTab.Index;
  Index := fFirstIndex;
  OrigStart := Start;

  if not Assigned(JumpTab) then
    bJumped := true;

  //Get the largest font width for the tabs
  actFont := GetGDIPFont(Canvas, fFont);
  tw := GetTextSize(Canvas, actFont, 'WOWOWOWOWOWOWOW').cx;
  actFont.Free;
  actFont := GetGDIPFont(Canvas, fSelectedFont);
  if tw > GetTextSize(Canvas, actFont, 'WOWOWOWOWOWOWOW').cx then
  begin
    actFont.Free;
    actFont := GetGDIPFont(Canvas, fFont);
  end;
  prevFont := actFont;
  actFont := GetGDIPFont(Canvas, fModifiedFont);
  if tw > GetTextSize(Canvas, actFont, 'WOWOWOWOWOWOWOW').cx then
  begin
    actFont.Free;
    actFont := prevFont;
  end
  else
    prevFont.Free;

  MaxTabWidth := 0;
  if FAutoTabWidth and (fTabs.Count > 0) then
    MaxTabWidth := (Stop div fTabs.Count) + fEdgeWidth;
  if (fMaxTabWidth > 0) and (MaxTabWidth > fMaxTabWidth) then
    MaxTabWidth := fMaxTabWidth;

  while (Start < Stop) and (Index < fTabs.Count) do begin
    Tab := fTabs[Index];
    Tab.fStartPos := Start;
    W := GetTextSize(Canvas, actFont, Tab.Caption).cx + fEdgeWidth * 2 + 10;
//    W := GetTextSize(Canvas, actFont, Tab.Caption).cx + fEdgeWidth * 2 - 1 ;   //Om: nov10: commented '+ 10' in the end.  Added '-1' instead...
    if fCloseTab then
      Inc(W, 10);
    if Assigned(fImages) and (Tab.ImageIndex > -1) then begin
      Inc(W, fImages.Width + 4);
    end;
    if (MaxTabWidth > 0) and (W > MaxTabWidth) then
      W := MaxTabWidth;

    //Calculate minimum tab width;
    reqWidth := fEdgeWidth * 2;
    if fCloseTab then Inc(reqWidth, 10);
    if Assigned(fImages) and (Tab.ImageIndex > -1) then Inc(reqWidth, fImages.Width + 4);
    if W < reqWidth then
      W := reqWidth;

    Tab.fSize := W;
    Inc(Start, Tab.fSize - fEdgeWidth);    { next usable position }
    if Tab = JumpTab then
      bJumped := true;

    if Start <= Stop then
      Inc(Index)
    else
    begin
      Tab.fStartPos := 0;
      Tab.fSize := 0;
      if not bJumped or (Tab = JumpTab) then
      begin
        ClearTabPositions;
        Inc(fFirstIndex);
        Index := fFirstIndex;
        Start := OrigStart;
        bJumped := false;
      end;
    end;
  end;
  Result := Index - fFirstIndex;
  actFont.Free;
end;

procedure TIceTabSet.CMHintShow(var Message: TCMHintShow);
var
  Item: TIceTab;
begin
  Item := GetItemFromPos(Message.HintInfo^.CursorPos.X, Message.HintInfo^.CursorPos.Y);
  if Assigned(Item) then
    Message.HintInfo^.HintStr := Item.Caption;
end;

function TIceTabset.GetGDIPFont(Canvas: TCanvas; Font: TFont): TGPFont;
var
  style: integer;
begin
  style := FontStyleRegular;
  if fsBold in Font.Style then
    style := style + FontStyleBold;
  if fsItalic in Font.Style then
    style := style + FontStyleItalic;
  if fsUnderLine in Font.Style then
    style := style + FontStyleUnderline;
  if fsStrikeOut in Font.Style then
    style := style + FontStyleStrikeout;

  result := TGPFont.Create(Font.Name, Font.Size, style, UnitPoint);
end;

function TIceTabset.GetTextSize(Canvas: TCanvas; Font: TGPFont; Text: string): TSize;
var
  graphics: TGPGraphics;
  rect: TGPRectF;
begin
  graphics := TGPGraphics.Create(Canvas.Handle);
  graphics.MeasureString(Text, -1, Font, MakePoint(0.0, 0.0), rect);
  result.cx := Round(rect.Width);
  result.cy := Round(rect.Height);

  graphics.Free;
end;

procedure TIceTabSet.Paint;
var
  I: Integer;
  TabStart, LastTabPos: integer;
  Tab: TIceTab;
  TabHeight: integer;

  graphics: TGPGraphics;
  linGrBrush: TGPLinearGradientBrush;

  fBuffer: TBitmap;
begin
  if not HandleAllocated then Exit;

  fBuffer := TBitmap.Create;
  fBuffer.SetSize(ClientRect.Right - ClientRect.Left, ClientRect.Bottom - ClientRect.Top);

  graphics := TGPGraphics.Create(fBuffer.Canvas.Handle);

  linGrBrush := TGPLinearGradientBrush.Create(
    MakePoint(0, ClientRect.Top),
    MakePoint(0, ClientRect.Bottom),
    MakeGDIPColor(FBackgroundStartColor),
    MakeGDIPColor(FBackgroundStopColor));
  graphics.FillRectangle(linGrBrush, MakeRect(ClientRect));

  linGrBrush.Free;
  graphics.Free;

  TabStart := 0;
  LastTabPos := Width - fScrollWidth;
  if FShowNewTab then
    Dec(LastTabPos,  fEdgeWidth + 10);
  fVisibleTabs := CalcTabPositions(TabStart, LastTabPos - fEdgeWidth, fBuffer.Canvas, nil);
  TabHeight := GetTabHeight;

  {  fScroller.Min := 0;
  fScroller.Max := fTabs.Count - fVisibleTabs;
  fScroller.Position := fFirstIndex; }

  //Draw all not selected tab
  for i := fFirstIndex + fVisibleTabs - 1 downto fFirstIndex do
  begin
    Tab := fTabs[i];
    if not Tab.Selected then
      InnerDraw(fBuffer.Canvas, Rect(Tab.fStartPos, ClientHeight - TabHeight, Tab.fStartPos + Tab.fSize,
        ClientHeight), Tab);
  end;

  //Draw the selected tab
  if Assigned(Selected) and (Selected.fSize > 0) then
    InnerDraw(fBuffer.Canvas, Rect(Selected.fStartPos, ClientHeight - TabHeight, Selected.fStartPos + Selected.fSize,
      ClientHeight), Selected);

  if FShowNewTab then
    DrawNewButton(fBuffer.Canvas);

  DrawScroll(fBuffer.Canvas);

  Canvas.Draw(ClientRect.Left, ClientRect.Top, fBuffer);
  fBuffer.Free;
end;

procedure TIceTabSet.DrawScroll(Canvas: TCanvas);
begin
  if fFirstIndex > 0 then
    DrawScrollLeftArrow(Canvas, fScrollLeft + BTN_MARGIN, fScrollTop + BTN_MARGIN, sbLeft, fScrollPushed = sbLeft);

  if fFirstIndex < fTabs.Count - fVisibleTabs then
  DrawScrollRightArrow(Canvas, fScrollLeft + BTN_SIZE + BTN_MARGIN, fScrollTop + BTN_MARGIN, sbRight, fScrollPushed = sbRight);
end;

procedure TIceTabSet.DrawScrollRightArrow(Canvas: TCanvas; X, Y: integer; Button: TScrollButton; State: boolean);
var
  graphics: TGPGraphics;
  path: TGPGraphicsPath;
  brush: TGPSolidBrush;
  innerRect: TRect;
begin
  if State then
  begin
    Canvas.Brush.Color := fArrowHighlightColor;
    Canvas.Rectangle(X - BTN_MARGIN, Y - 1, X + BTN_SIZE - BTN_MARGIN, Y + BTN_SIZE);
  end;

  graphics := TGPGraphics.Create(Canvas.Handle);
  graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  path := TGPGraphicsPath.Create();
  innerRect := Rect(X + 2, Y + 2, X + 2 + 6, Y + 2 + 8);
  path.AddLine(innerRect.Left, innerRect.Top, InnerRect.Right, InnerRect.Top + 4);
  path.AddLine(innerRect.Right, innerRect.Top + 4, InnerRect.Left, InnerRect.Bottom);
  path.AddLine(innerRect.Left, innerRect.Bottom, InnerRect.Left, InnerRect.Top);

  brush:= TGPSolidBrush.Create(MakeGDIPColor(fArrowColor));
  graphics.FillPath(brush, path);

  brush.Free;
  path.Free;
  graphics.Free;
end;

procedure TIceTabSet.DrawScrollLeftArrow(Canvas: TCanvas; X, Y: integer; Button: TScrollButton; State: boolean);
var
  graphics: TGPGraphics;
  path: TGPGraphicsPath;
  brush: TGPSolidBrush;
  innerRect: TRect;
begin
  if State then
  begin
    Canvas.Brush.Color := fArrowHighlightColor;
    Canvas.Rectangle(X, Y - 1, X + BTN_SIZE, Y + BTN_SIZE);
  end;

  graphics := TGPGraphics.Create(Canvas.Handle);
  graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  path := TGPGraphicsPath.Create();
  innerRect := Rect(X + 3, Y + 2, X + 3 + 6, Y + 2 + 8);
  path.AddLine(innerRect.Right, innerRect.Top, InnerRect.Left, InnerRect.Top + 4);
  path.AddLine(innerRect.Left, innerRect.Top + 4, InnerRect.Right, InnerRect.Bottom);
  path.AddLine(innerRect.Right, innerRect.Bottom, InnerRect.Right, InnerRect.Top);

  brush:= TGPSolidBrush.Create(MakeGDIPColor(fArrowColor));
  graphics.FillPath(brush, path);

  brush.Free;
  path.Free;
  graphics.Free;
end;

procedure TIceTabSet.DrawNewButton(Canvas: TCanvas);
var
  graphics : TGPGraphics;
  Pen: TGPPen;
  path, linePath: TGPGraphicsPath;
  linGrBrush: TGPLinearGradientBrush;
  solidBrush: TGPSolidBrush;
  borderColor: Cardinal;
  TabHeight, LastPos: integer;
  X1, Y1, X2, Y2, FixLine: integer;
  dX, dY: Extended;
  signW, I: integer;
  plusSign: array [0..12] of TGPPointF;
  fillColor1, fillColor2, plusColor: Cardinal;
begin
  graphics := TGPGraphics.Create(Canvas.Handle);
  graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  if FHighlightNewButton then
  begin
    fillColor1 := MakeColor(160, 255, 255, 255);
    fillColor2 := MakeColor(128, 255, 255, 255);
    plusColor := MakeColor(255, 255, 255, 255);
  end
  else
  begin
    fillColor1 := MakeColor(128, 255, 255, 255);
    fillColor2 := MakeColor(64, 255, 255, 255);
    plusColor := MakeColor(200, 255, 255, 255);
  end;


  borderColor := MakeGDIPColor(fTabBorderColor); // MakeColor(255, 83, 100, 112);
  Pen:= TGPPen.Create(borderColor);

  LastPos := Width - fScrollWidth;
  TabHeight := GetTabHeight;
  FixLine := 14;

  X1 := 0;
  for I := fFirstIndex + fVisibleTabs - 1 downto fFirstIndex do
    if (fTabs[i].fStartPos + fTabs[i].fSize) > X1 then
      X1 := fTabs[i].fStartPos + fTabs[i].fSize;

  //X1 := LastPos - fEdgeWidth;
  Y1 := ClientHeight - TabHeight + 3;
  X2 := X1 + FixLine + fEdgeWidth div 2 + 5;
  Y2 := Y1 + TabHeight - 8;

  FNewButtonArea := Rect(X1, Y1, X2, Y2);

  path := TGPGraphicsPath.Create();
  path.AddEllipse(MakeRect(X1, (ClientHeight - 18) / 2, 18, 18));
{  path.AddLine(X1, Y1, X1 + FixLine, Y1);
  path.AddBezier(
    X1 + FixLine, Y1, X2 - 2, Y1 + 1,
    X2 - 2, Y2, X2, Y2);
  path.AddLine(X2, Y2, X2 - FixLine, Y2);
  path.AddBezier(
    X2 - FixLine, Y2, X1 - 2, Y2 - 1,
    X1 + 2, Y1, X1, Y1); }

  linePath := TGPGraphicsPath.Create();
  linePath.AddPath(path, false);

  linGrBrush := TGPLinearGradientBrush.Create(
    MakePoint(0, Y1),
    MakePoint(0, Y2),
    fillColor1, fillColor2);

  graphics.DrawPath(pen, linePath);
  graphics.FillPath(linGrBrush, path);

  //Draw + sign
  signW := 3;
  dX := 9 - signW * 1.5;
  dY := ((ClientHeight - 18) / 2) - signW * 1.5;
//  dX := (X2 - X1)/2 - signW * 1.5;
//  dY := (Y2 - Y1)/2 - signW * 1.5;

  plusSign[0] := MakePoint(X1 + dx, Y1 + dY + signW);
  plusSign[1] := MakePoint(X1 + dx + signW, Y1 + dY + signW);
  plusSign[2] := MakePoint(X1 + dx + signW, Y1 + dY);
  plusSign[3] := MakePoint(X1 + dx + signW * 2, Y1 + dY);
  plusSign[4] := MakePoint(X1 + dx + signW * 2, Y1 + dY + signW);
  plusSign[5] := MakePoint(X1 + dx + signW * 3, Y1 + dY + signW);
  plusSign[6] := MakePoint(X1 + dx + signW * 3, Y1 + dY + signW * 2);
  plusSign[7] := MakePoint(X1 + dx + signW * 2, Y1 + dY + signW * 2);
  plusSign[8] := MakePoint(X1 + dx + signW * 2, Y1 + dY + signW * 3);
  plusSign[9] := MakePoint(X1 + dx + signW, Y1 + dY + signW * 3);
  plusSign[10]:= MakePoint(X1 + dx + signW, Y1 + dY + signW * 2);
  plusSign[11]:= MakePoint(X1 + dx, Y1 + dY + signW * 2);
  plusSign[12]:= MakePoint(X1 + dx, Y1 + dY + signW);

  path.Reset;
  path.AddLines(PGPPointF(@plusSign), 13);

  linePath.Reset;
  linePath.AddPath(path, false);

  solidBrush := TGPSolidBrush.Create(plusColor);

  graphics.DrawPath(pen, linePath);
  graphics.FillPath(solidBrush, path);

  pen.Free;
  linePath.Free;
  path.Free;
  linGrBrush.Free;
  solidBrush.Free;
  graphics.Free;
end;

procedure TIceTabSet.InnerDraw(Canvas: TCanvas; TabRect: TRect; Item: TIceTab);
var
  graphics : TGPGraphics;
  Pen: TGPPen;
  path, linePath: TGPGraphicsPath;
  linGrBrush: TGPLinearGradientBrush;

  font: TGPFont;
  pointF: TGPPointF;
  solidBrush, mainBrush: TGPSolidBrush;

  rectF: TGPRectF;
  stringFormat: TGPStringFormat;
  DC: HDC;
  marginRight: integer;

  iconY, iconX: integer;
  textStart: Extended;

  startColor, EndColor, textColor, borderColor: cardinal;
begin
  DC := Canvas.Handle;

  if Item.Selected then
  begin
    startColor := MakeGDIPColor(FSelectedTabStartColor); // MakeColor(255, 247, 249, 251);
    endColor := MakeGDIPColor(FSelectedTabStopColor); // MakeColor(255, 225, 230, 234);
    textColor := MakeGDIPColor(fSelectedFont.Color); // MakeColor(255, 0, 0, 0);
  end
  else if Item.Modified then
  begin
    startColor := MakeGDIPColor(FModifiedTabStartColor);
    endColor := MakeGDIPColor(FModifiedTabStopColor);
    textColor := MakeGDIPColor(fModifiedFont.Color);
  end
  else
  begin
    startColor := MakeGDIPColor(FTabStartColor);
    endColor := MakeGDIPColor(FTabStopColor);
    textColor := MakeGDIPColor(fFont.Color); // MakeColor(255, 255, 255, 255);
  end;
  borderColor := MakeGDIPColor(fTabBorderColor); // MakeColor(255, 83, 100, 112);

  graphics := TGPGraphics.Create(DC);
  graphics.SetSmoothingMode(SmoothingModeAntiAlias);
  Pen:= TGPPen.Create(borderColor);

  path := TGPGraphicsPath.Create();
  path.AddBezier(TabRect.Left, TabRect.Bottom, TabRect.Left + fEdgeWidth / 2, TabRect.Bottom, TabRect.Left + fEdgeWidth / 2, TabRect.Top, TabRect.Left + fEdgeWidth, TabRect.Top);
  path.AddLine(TabRect.Left + fEdgeWidth, TabRect.Top, TabRect.Right - fEdgeWidth, TabRect.Top);
  path.AddBezier(TabRect.Right - fEdgeWidth, TabRect.Top, TabRect.Right - fEdgeWidth / 2, TabRect.Top, TabRect.Right - fEdgeWidth / 2, TabRect.Bottom, TabRect.Right, TabRect.Bottom);
  linePath := TGPGraphicsPath.Create();
  linePath.AddPath(path, false);
  path.AddLine(TabRect.Right, TabRect.Bottom, TabRect.Left, TabRect.Bottom);

  linGrBrush := TGPLinearGradientBrush.Create(
    MakePoint(0, TabRect.Top),
    MakePoint(0, TabRect.Bottom),
    startColor,
    endColor);

  graphics.DrawPath(pen, linePath);
  graphics.FillPath(linGrBrush, path);

  marginRight := 0;
  if fCloseTab then
  begin
    pen.SetWidth(2);
    if HighLightTabClose = Item then
      pen.SetColor(MakeGDIPColor(clRed))
    else
      pen.SetColor(MakeGDIPColor(fTabCloseColor));

    graphics.DrawLine(pen, TabRect.Right - fEdgeWidth - 7, TabRect.Top + ((TabRect.Bottom - TabRect.Top - 7) div 2),
                           TabRect.Right - fEdgeWidth, TabRect.Top + ((TabRect.Bottom - TabRect.Top + 7) div 2));

    graphics.DrawLine(pen, TabRect.Right - fEdgeWidth, TabRect.Top + ((TabRect.Bottom - TabRect.Top - 7) div 2),
                           TabRect.Right - fEdgeWidth - 7, TabRect.Top + ((TabRect.Bottom - TabRect.Top + 7) div 2));
    marginRight := 10;
  end;

  if Item.Selected then
    font := GetGDIPFont(Canvas, fSelectedFont)
  else if Item.Modified then
    font := GetGDIPFont(Canvas, fModifiedFont)
  else
    font := GetGDIPFont(Canvas, fFont);

  solidBrush:= TGPSolidBrush.Create(textColor);
  stringFormat:= TGPStringFormat.Create;
  stringFormat.SetAlignment(StringAlignmentNear);
  stringFormat.SetLineAlignment(StringAlignmentCenter);
  stringFormat.SetTrimming(StringTrimmingEllipsisCharacter);
  stringFormat.SetFormatFlags(StringFormatFlagsNoWrap);

  SelectClipRgn(Canvas.Handle, 0);
  textStart := TabRect.Left + fEdgeWidth;
  if Assigned(Images) and (Item.ImageIndex <> -1) then
  begin
    iconY := TabRect.Top + ((TabRect.Bottom - TabRect.Top - Images.Height) div 2);
    iconX := Round(textStart);
    textStart := textStart + Images.Width + 4;
  end;

  rectF := MakeRect(textStart, TabRect.Top, TabRect.Right - textStart - fEdgeWidth - marginRight,
    TabRect.Bottom - TabRect.Top);
//  graphics.SetClip(rectF);
  if rectF.Width > 10 then
    graphics.DrawString(Item.Caption, -1, font, rectF, stringFormat, solidBrush);
//  graphics.ResetClip;

//  mainBrush := TGPSolidBrush.Create(endColor);

  font.Free;
  solidBrush.Free;
  linGrBrush.Free;
  linePath.Free;
  path.Free;
  Pen.Free;
  graphics.Free;

  if Assigned(Images) and (Item.ImageIndex <> -1) then
    Images.Draw(Canvas, iconX, iconY, Item.ImageIndex, true);
end;

procedure TIceTabSet.SetCloseTab(const Value: boolean);
begin
  if FCloseTab <> Value then begin
    FCloseTab := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetEdgeWidth(const Value: integer);
begin
  if FEdgeWidth <> Value then begin
    FEdgeWidth := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  Tab: TIceTab;
begin
  inherited;


  Tab := GetItemFromPos(Message.XPos, Message.YPos);
  if Assigned(Tab) then
    DoDoubleClick(Tab);
end;

procedure TIceTabSet.WMSize(var Message: TWMSize);
begin
  inherited;
  fScrollTop := (Height div 2) - (fScrollHeight div 2);
  fScrollLeft := Width - fScrollWidth - 1;
  Invalidate;
end;

function TIceTabSet.GetButtonRect(const AButton: TScrollButton): TRect;
begin
  Result.Left := fScrollLeft + Ord(AButton) * BTN_SIZE;
  Result.Top := fScrollTop;
  Result.Bottom := fScrollTop + fScrollHeight;
  Result.Right := Result.Left + BTN_SIZE;
end;

function TIceTabSet.AddTab(const ACaption: string; const ImageIndex: integer = -1; const Data: TObject = nil): TIceTab;
begin
  Result := fTabs.Add as TIceTab;
  Result.Caption := ACaption;
  Result.Data := Data;
  Result.ImageIndex := ImageIndex;
  Invalidate;
end;

function TIceTabSet.IndexOfTabData(Data: TObject): integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to fTabs.Count - 1 do
    if fTabs[I].Data = Data then
    begin
      result := I;
      Exit;
    end;
end;

function TIceTabSet.RemoveTab(ATab: TIceTab): integer;
var
  s: boolean;
  i: integer;
begin
  Result := fTabs.IndexOf(ATab);
  if Result <> -1 then
  begin
    s := ATab.Selected;
    i := ATab.Index;
    fTabs.Delete(Result);
    if s then
    begin
      if (i >= 0) and (i < fTabs.Count) then
        SetTabIndex(i)
      else if i >= fTabs.Count then
        SetTabIndex(fTabs.Count - 1);
    end;
    Invalidate;
  end;
end;

procedure TIceTabSet.TabSelected(ATab: TIceTab; ASelected: boolean);
begin
  if ASelected then
  begin
    LookThisTab(ATab);
    fTabIndex := ATab.Index;
  end;
  if Assigned(fOnTabSelected) then
    fOnTabSelected(Self, ATab, ASelected);
end;

procedure TIceTabSet.SetFont(Value: TFont);
begin
  fFont.Assign(Value);
  Invalidate;
end;

procedure TIceTabSet.SetHighlightNewButton(const Value: boolean);
begin
  if FHighlightNewButton <> Value then
  begin
    FHighlightNewButton := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetHighlightTabClose(const Value: TIceTab);
begin
  if FHighlightTabClose <> Value then
  begin
    FHighlightTabClose := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetImages(const Value: TCustomImageList);
begin
  if fImages <> Value then
  begin
    fImages := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetSelectedFont(Value: TFont);
begin
  fSelectedFont.Assign(Value);
  Invalidate;
end;

procedure TIceTabSet.SetSelectedTabStartColor(const Value: TColor);
begin
  if FSelectedTabStartColor <> Value then
  begin
    FSelectedTabStartColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetSelectedTabStopColor(const Value: TColor);
begin
  if FSelectedTabStopColor <> Value then
  begin
    FSelectedTabStopColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetShowNewTab(const Value: boolean);
begin
  if FShowNewTab <> Value then
  begin
    FShowNewTab := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetArrowColor(const Value: TColor);
begin
  if FArrowColor <> Value then begin
    FArrowColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetArrowHighlightColor(const Value: TColor);
begin
  if FArrowHighlightColor <> Value then
  begin
    FArrowHighlightColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetAutoTabWidth(const Value: boolean);
begin
  if FAutoTabWidth <> Value then
  begin
    FAutoTabWidth := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetBackgroundStartColor(const Value: TColor);
begin
  if FBackgroundStartColor <> Value then begin
    FBackgroundStartColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetBackgroundStopColor(const Value: TColor);
begin
  if FBackgroundStopColor <> Value then begin
    FBackgroundStopColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.DrawDragTabPointer(aTabIndex:integer); //Om:
var
  x, yMx: integer;
  Pts: Array[0..2] of TPoint;
  innerRect: TRect;

  graphics: TGPGraphics;
  path: TGPGraphicsPath;
  brush: TGPSolidBrush;

begin
  if (aTabIndex >= 0) and (aTabIndex < fTabs.Count) then
  begin
    x := fTabs[aTabIndex].fStartPos;
    yMx := Height;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Mode := pmNot;
    Canvas.Pen.Style := psSolid;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := fArrowColor;

    Pts[0] := Point(x   , 0);
    Pts[1] := Point(x+3 , 6);
    Pts[2] := Point(x+6 , 0);

    Canvas.Polygon(Pts); //drag tab cursor = triangle
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Mode := pmCopy;
  end;
end;

procedure TIceTabSet.DragOver( Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean ); //Om:
var
  Ix: Integer;
  R: TRect;
  Tab: TIceTab;
begin
  inherited;

  Accept := false;
  if fCanDragTabs and (Source = Self) then // we're NOT accepting drags from other IceTabSets
  begin
    Tab := GetItemFromPos(X, Y);
    if Assigned(Tab) then
    begin
      Ix := fTabs.IndexOf(Tab);
      Accept := (Ix <> -1) and (Ix <> fIxTabStartDrag);

      if (Ix <> fIxTabStartDrag) then
      begin
        if fTabDragPointerVisible and (fIxTabEndDrag >= 0) then
          DrawDragTabPointer( fIxTabEndDrag ); //erase pointer

        fIxTabEndDrag := Ix;

        if Accept then
        begin
          DrawDragTabPointer( fIxTabEndDrag );
          fTabDragPointerVisible := True;
        end
        else if fTabDragPointerVisible then
        begin
          DrawDragTabPointer( fIxTabEndDrag );
          fTabDragPointerVisible := False;
        end;
      end;
    end;

    if (State = dsDragLeave) and fTabDragPointerVisible then
    begin
      DrawDragTabPointer( fIxTabEndDrag );
      fTabDragPointerVisible := False;
    end;
  end;
end;

procedure TIceTabSet.DoTabEndDrag; //Om: mova tab from fIxTabStartDrag to fIxTabEndDrag
var
  Tab: TIceTab;
begin
  if fCanDragTabs and (fIxTabStartDrag >= 0) and (fIxTabEndDrag >= 0) and (fIxTabStartDrag <> fIxTabEndDrag) then
    begin
      Tab := fTabs[fIxTabStartDrag];
      Tab.Index := fIxTabEndDrag; //change tab index
      fTabs.DoSelected(Tab, true);
    end;
end;

procedure TIceTabSet.DragDrop( Source: TObject; X, Y: Integer ); //Om: drop event
var
  Ix: Integer;
  Tab: TIceTab;
begin
  if fCanDragTabs and ( Source = Self ) then
  begin
    if fTabDragPointerVisible then
      DrawDragTabPointer( fIxTabEndDrag  ); //apaga

    fTabDragPointerVisible := false;

    DoTabEndDrag;
    fIxTabStartDrag := -1; //reset dragging
  end;

  inherited;
end;

procedure TIceTabSet.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Tab: TIceTab;
  scrollRect: TRect;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if (Button = mbLeft) then
  begin
    Tab := GetItemFromPos(X, Y);
    if Assigned(Tab) then
    begin
      SetTab(Tab);
      fIxTabStartDrag := fTabs.IndexOf(Tab); //Om: save start drag tab
    end
    else
    begin
      //Check scroll buttons
      scrollRect := Rect(fScrollLeft + BTN_MARGIN, fSCrollTop + BTN_MARGIN, fScrollLeft + BTN_MARGIN + BTN_SIZE, fScrollTop + BTN_MARGIN + BTN_SIZE);
      if PtInRect(scrollRect, Point(X, Y)) and (fFirstIndex > 0) then
      begin
        fScrollPushed := sbLeft;
        Invalidate;
      end
      else
      begin
        scrollRect := Rect(fScrollLeft + BTN_MARGIN + BTN_SIZE, fSCrollTop + BTN_MARGIN, fScrollLeft + BTN_MARGIN + (BTN_SIZE * 2), fScrollTop + BTN_MARGIN + BTN_SIZE);
        if PtInRect(scrollRect, Point(X, Y)) and (fFirstIndex < fTabs.Count - fVisibleTabs) then
        begin
          fScrollPushed := sbRight;
          Invalidate;
        end;
      end;
    end;
  end;
end;

function TIceTabSet.GetItemFromPos(X, Y: integer): TIceTab;
var
  th, I, MinLeft, MaxRight: integer;
begin
  result := nil;
  th := GetTabHeight;
  if (Y <= ClientHeight) and (Y >= ClientHeight - th) then
  begin
    for I := fFirstIndex to fTabs.Count - 1 do
    begin
      MinLeft := fTabs.Items[i].fStartPos;
      MaxRight := fTabs.Items[i].fStartPos + fTabs.Items[i].fSize;
      if (X >= MinLeft) and (X <= MaxRight) then
      begin
        result := fTabs.Items[I];
        Break;
      end;
    end;
  end;
end;

procedure TIceTabSet.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Tab: TIceTab;
begin
  inherited MouseMove(Shift, X, Y);

  Tab := GetItemFromPos(X, Y);
  if FCloseTab then
  begin
    if Assigned(Tab) and IsInCloseButton(Tab, X, Y) then
      HighlightTabClose := Tab
    else
      HighlightTabClose := nil;
  end;
  if FShowNewTab then
  begin
    HighlightNewButton := ptInRect(FNewButtonArea, Point(X, Y));
  end;

  if fCanDragTabs and (ssLeft in Shift) and (fIxTabStartDrag >= 0)  then  //Om: Start dragging the tab
    BeginDrag( False );
end;

function TIceTabSet.IsInCloseButton(ATab: TIceTab; X, Y: integer): boolean;
var
  closeRect: TRect;
  TabRight, TabTop: integer;
begin
  TabRight := ATab.fStartPos + ATab.fSize;
  TabTop := Height - TabHeight;

  closeRect := Rect(TabRight - fEdgeWidth - 9,
                    TabTop + ((Height - TabTop - 10) div 2),
                    TabRight - fEdgeWidth + 2,
                    TabTop + ((Height - TabTop + 10) div 2));
  result := PtInRect(closeRect, Point(X, Y));

end;

procedure TIceTabSet.LookThisTab(ATab: TIceTab);
var
  Start, Stop: integer;
begin
  if Assigned(ATab) then
  begin
    Start := 0;
    Stop := Width - fScrollWidth - fEdgeWidth;
    if FShowNewTab then
      Dec(Stop,  fEdgeWidth + 10);
    CalcTabPositions(Start, Stop, Canvas, ATab);

    Invalidate;
  end;
end;

procedure TIceTabSet.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  Tab: TIceTab;
begin
  inherited;


  Tab := GetItemFromPos(X, Y);
  if Assigned(Tab) and FCloseTab and IsInCloseButton(Tab, X, Y) then
  begin
    if Assigned(OnTabClose) then
      OnTabClose(Self, Tab);
  end;
  if FShowNewTab then
  begin
    if ptInRect(FNewButtonArea, Point(X, Y)) then
      if Assigned(OnNewButtonClick) then
      begin
        OnNewButtonClick(Self);
      end;
  end;

  if fScrollPushed <> sbNone then
  begin
    ScrollClick(fScrollPushed);
    fScrollPushed := sbNone;
    Invalidate;
  end;
end;

function TIceTabSet.GetTabHeight: integer;
begin
  Result := FTabHeight;
end;

procedure TIceTabSet.SetTab(NewTab: TIceTab);
begin
  if Assigned(NewTab) then
    NewTab.Selected := true
  else
    TabIndex := -1;
end;

procedure TIceTabSet.SetTabIndex(Value: Integer);
var
  t: TIceTab;
begin
//  if fTabIndex <> Value then
  begin
    fTabIndex := Value;
    if (Value < -1) or (Value >= fTabs.Count) then
      raise Exception.CreateRes(@SInvalidTabIndex);
    if Value <> -1 then
    begin
      t := fTabs.Items[Value];
      t.Selected := true;
    end
    else
      ClearSelection;
  end;
end;

procedure TIceTabSet.ClearSelection;
var
  I: Integer;
begin
  for I := 0 to fTabs.Count - 1 do
    fTabs[I].Selected := false;
end;

procedure TIceTabSet.SetTabStartColor(const Value: TColor);
begin
  if FTabStartColor <> Value then
  begin
    FTabStartColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetTabStopColor(const Value: TColor);
begin
  if FTabStopColor <> Value then
  begin
    FTabStopColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.ShowRightPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  Tab: TIceTab;
  Poz: TPoint;
begin
  Poz := Mouse.CursorPos;
  Tab := GetItemFromPos(MousePos.X, MousePos.Y);
  if Assigned(OnBeforeShowPopupMenu) then
    OnBeforeShowPopupMenu(Self, Tab, MousePos);

  if Assigned(PopupMenu) then
  begin
    Handled := true;
    PopupMenu.Popup(Poz.X, Poz.Y);
  end;
end;

procedure TIceTabSet.SelectNext(ANext: boolean);
var
  NewIndex: Integer;
begin
  if fTabs.Count > 1 then
  begin
    NewIndex := fTabIndex;
    if ANext then
      Inc(NewIndex)
    else
      Dec(NewIndex);
    if NewIndex = fTabs.Count then
      NewIndex := 0
    else if NewIndex < 0 then
      NewIndex := fTabs.Count - 1;
    SetTabIndex(NewIndex);
  end;
end;

function TIceTabSet.GetSelected: TIceTab;
begin
  if (fTabIndex > -1) and (fTabIndex < fTabs.Count) then
    Result := fTabs[fTabIndex]
  else
    Result := nil;
end;

procedure TIceTabSet.SetSelected(Value: TIceTab);
begin
  if Assigned(Value) then
    Value.Selected := true;
end;

procedure TIceTabSet.SetModifiedFont(const Value: TFont);
begin
  FModifiedFont.Assign(Value);
  Invalidate;
end;

procedure TIceTabSet.SetModifiedTabStartColor(const Value: TColor);
begin
  if FModifiedTabStartColor <> Value then
  begin
    FModifiedTabStartColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetModifiedTabStopColor(const Value: TColor);
begin
  if FModifiedTabStopColor <> Value then
  begin
    FModifiedTabStopColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetOnBeforeShowPopupMenu(
  const Value: TBeforeShowPopupMenuEvent);
begin
  FOnBeforeShowPopupMenu := Value;
end;

procedure TIceTabSet.SetOnDblClick(const Value: TTabCloseEvent);
begin
  FOnDblClick := Value;
end;

procedure TIceTabSet.SetOnNewButtonClick(const Value: TNotifyEvent);
begin
  FOnNewButtonClick := Value;
end;

procedure TIceTabSet.SetOnTabClose(const Value: TTabCloseEvent);
begin
  FOnTabClose := Value;
end;

procedure TIceTabSet.SetTabBorderColor(Value: TColor);
begin
  if fTabBorderColor <> Value then begin
    fTabBorderColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetTabCloseColor(const Value: TColor);
begin
  if FTabCloseColor <> Value then begin
    FTabCloseColor := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetTabHeight(const Value: integer);
begin
  if FTabHeight <> Value then begin
    FTabHeight := Value;
    Invalidate;
  end;
end;

procedure TIceTabSet.SetMaxTabWidth(Value: integer);
begin
  if fMaxTabWidth <> Value then begin
    fMaxTabWidth := Value;
    Invalidate;
  end;
end;

end.
