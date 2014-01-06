module HealthInspector
  module Color

    # TODO: Use a highline color scheme here instead
    def color(type, str)
      colors = {
        'pass'          => [:green],# 90,
        'fail'          => [:red],# 31,
        'bright pass'   => [:bold, :green],# 92,
        'bright fail'   => [:bold, :red],# 91,
        'bright yellow' => [:bold, :yellow],# 93,
        'pending'       => [:yellow],# 36,
        'suite'         => [],# 0,
        'error title'   => [],# 0,
        'error message' => [:red],# 31,
        'error stack'   => [:green],# 90,
        'checkmark'     => [:green],# 32,
        'fast'          => [:green],# 90,
        'medium'        => [:green],# 33,
        'slow'          => [:red],# 31,
        'green'         => [:green],# 32,
        'light'         => [:green],# 90,
        'diff gutter'   => [:green],# 90,
        'diff added'    => [:green],# 42,
        'diff removed'  => [:red]# 41
      }

      @context.knife.ui.color(str, *colors[type])
    end
  end
end
