# frozen_string_literal: true

module BlogsHelper
  def format_content(blog)
    sanitize(html_escape(blog.content).gsub("\n", '<br>'))
  end
end
