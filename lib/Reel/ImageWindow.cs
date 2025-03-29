using System.IO;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Interop;

namespace Reel;

public /* partial */ class ImageWindow : Window
{
    public const double DEFAULT_WIDTH = 200; // 400
    public const double MIN_OPACITY = 0.5;
    public const double MAX_OPACITY = 1.0;
    public const double DELTA_OPACITY = 0.001;
    public const double DEFAULT_START_OPACITY = 0.8;
    private readonly Image _imageControl = new();

    // private const int WS_EX_TRANSPARENT = 0x00000020;
    // private const int WS_EX_LAYERED     = 0x00080000;
    // private const int GWL_EXSTYLE       = -20;

    // [LibraryImport("user32.dll", EntryPoint = "GetWindowLongA", SetLastError = true)]
    // private static partial int GetWindowLong(IntPtr hwnd, int nIndex);

    // [LibraryImport("user32.dll", EntryPoint = "SetWindowLongA")]
    // private static partial int SetWindowLong(IntPtr hwnd, int nIndex, int dwNewLong);

    private ImageWindow()
    {
        Width = DEFAULT_WIDTH;
        WindowStyle = WindowStyle.None;
        WindowState = WindowState.Normal;
        AllowsTransparency = true;
        SizeToContent = SizeToContent.Width;
        Background = Brushes.Transparent;
        Topmost = true;
        ShowInTaskbar = false;
        Content = ImageControl;
        _imageControl.Opacity = ImageOpacity;
        PreviewMouseWheel += ImageWindow_PreviewMouseWheel;
        // Loaded += ImageWindow_Loaded;
    }

    // private void
    // ImageWindow_Loaded(
    //     object sender,
    //     RoutedEventArgs e
    // ) {
    //     IntPtr hwnd = new WindowInteropHelper(this).Handle;
    //     int extendedStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
    //     _ = SetWindowLong(hwnd, GWL_EXSTYLE, extendedStyle | WS_EX_TRANSPARENT | WS_EX_LAYERED);
    // }

    private void
    ImageWindow_PreviewMouseWheel(
        object sender,
        System.Windows.Input.MouseWheelEventArgs e
    ) {
        ImageOpacity += e.Delta * DELTA_OPACITY;
        _imageControl.Opacity = ImageOpacity;
    }

    public Image ImageControl => _imageControl;

    public async Task UpdateImageAsync(string imagePath)
    {
        if (!File.Exists(imagePath))
            return;

        await Application.Current.Dispatcher.BeginInvoke(() =>
        {
            ImageControl.Source = new BitmapImage(new Uri(imagePath, UriKind.Absolute));
        });
    }

    // public async Task SetClickThroughAsync(bool enable)
    // {
    //     await Application.Current.Dispatcher.BeginInvoke(() =>
    //     {
    //         IntPtr hwnd = new WindowInteropHelper(this).Handle;
    //         int extendedStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

    //         _ = SetWindowLong(hwnd, GWL_EXSTYLE, enable
    //             ? extendedStyle | WS_EX_TRANSPARENT
    //             : extendedStyle & ~WS_EX_TRANSPARENT
    //         );
    //     });
    // }

    private static Thread? _uiThread;
    private static Application? _app;
    private static ImageWindow? _window;
    private static double _imageOpacity = DEFAULT_START_OPACITY;
    private static readonly AutoResetEvent _appReady = new(false);

    // Hide the window
    public static void HideWindow()
    {
        if (_window == null)
            return;

        Application.Current.Dispatcher.Invoke(() => _window.Visibility = Visibility.Hidden);
    }

    // Unhide the window (make it visible again)
    public static void UnhideWindow()
    {
        _window ??= ShowWindow();
        Application.Current.Dispatcher.Invoke(() => _window.Visibility = Visibility.Visible);
    }

    public static bool AppConstructed { get; private set; } = false;
    public static bool Visible => _window?.Visibility == Visibility.Visible;
    public static AutoResetEvent AppReady => _appReady;

    // // Not thread-safe
    // public static ImageWindow? CurrentWindow => _window;

    public static double ImageOpacity
    {
        get => _imageOpacity;
        set
        {
            _imageOpacity = value < MIN_OPACITY
                ? MIN_OPACITY
                : (value > MAX_OPACITY
                    ? MAX_OPACITY
                    : value);
        }
    }

    public static ImageWindow ShowWindow()
    {
        if (AppConstructed || _window != null)
            return _window; // Already open

        if (_uiThread == null || !_uiThread.IsAlive)
        {
            AppConstructed = true;

            _uiThread = new Thread(() =>
            {
                _app = new Application();
                _app.Startup += (s, e) => AppReady.Set();
                _app.Run();
            });

            _uiThread.SetApartmentState(ApartmentState.STA);
            _uiThread.IsBackground = true;
            _uiThread.Start();
            AppReady.WaitOne(); // Wait until Application starts
        }

        Application.Current.Dispatcher.Invoke(() =>
        {
            if (_window == null)
            {
                _window = new ImageWindow();
                _window.Closed += (s, e) => _window = null;
                _window.Show();
            }
        });

        return _window;
    }

    public static async Task SetImageAsync(string imagePath)
    {
        if (_window == null)
            return;

        await _window.Dispatcher.InvokeAsync(() => _window.UpdateImageAsync(imagePath));
    }

    public static async Task SetWidthAsync(int width)
    {
        if (_window == null)
            return;

        await _window.Dispatcher.InvokeAsync(() => _window.Width = width);
    }

    // // todo: Remove or refactor. This method will cause the host process to crash.
    // public static void CloseWindow()
    // {
    //     _window?.Dispatcher.Invoke(() => _window.Close());
    //     Application.Current.Dispatcher.Invoke(() => _app?.Shutdown());
    //     _uiThread?.Join(); // Ensure the thread fully exits
    // }
}

