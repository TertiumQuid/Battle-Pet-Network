require 'test_helper'
require 'action_view/test_case'
require 'action_view/helpers'

class Facebook::FacebookHelperTest < ActionView::TestCase
  def test_facebook_link_to
    [facebook_root_path,facebook_index_path,new_facebook_biography_path].each do |p|
      assert p.include?('/facebook')
      assert !facebook_link_to('test', p).include?('/facebook')
    end
  end  
end