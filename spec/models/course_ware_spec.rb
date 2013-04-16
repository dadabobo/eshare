require 'spec_helper'

describe CourseWare do

  describe 'link file_entity' do
    before do
      @course_ware = FactoryGirl.create(:course_ware)
      @user = FactoryGirl.create(:user)

      @file_entity = FileEntity.create(
        :attach => File.new(Rails.root.join("spec/data/file_entity.jpg")))

    end

    it{
      @course_ware.file_entity.should == nil
    }

    describe 'set file_entity' do
      before do
        @course_ware.file_entity = @file_entity
        @course_ware.save
        @course_ware.reload
        @media_resource = MediaResource.last
      end

      it {
        @course_ware.file_entity.should == @file_entity  
      }

      it {
        @course_ware.kind.should == 'image'
      }

      it {
        MediaResource.last.file_entity.should == @file_entity
      }

      it {
        @course_ware.media_resource.should == @media_resource
      }

      it {
        @media_resource.destroy
        @course_ware.reload
        @course_ware.media_resource.should be_blank
      }

      describe 'update course_ware' do
        before{
          @course_ware.title = 'gai'
          @course_ware.save
          @course_ware.reload
        }

        it{
          @course_ware.media_resource.should == @media_resource
        }

        describe 'update file_entity' do
          before{
            @file_entity_1 = FileEntity.create(
              :attach => File.new(Rails.root.join("spec/data/file_entity.jpg")))

            @course_ware.file_entity = @file_entity_1
            @course_ware.save
            @course_ware.reload
          }

          it{
            @course_ware.media_resource.should_not == @media_resource
          }

          it{
            @course_ware.file_entity.should == @file_entity_1
          }

          it{
            @course_ware.media_resource.should == MediaResource.last
          }
        end
      end
    end

  end


  context '课程进度: 记录课件的已读状态' do
    before do
      @course_ware   = FactoryGirl.create(:course_ware, :total_count => nil)
      @course_ware1  = FactoryGirl.create(:course_ware, :total_count => 3)
      @user          = FactoryGirl.create(:user)
    end
    
    describe '#sign_read_count' do
      context '验证 read_count < total_count' do
        it {
          expect {
            @course_ware1.update_read_count_of(@user, 1)
          }.to change {
            @course_ware1.readed_users_count
          }.by(0)
        }
      end
      context '验证 read_count = total_count' do
        it{expect {@course_ware1.update_read_count_of(@user,3)}.to change {@course_ware1.readed_users_count}.by(1)}
      end
      context '标记为未读' do
        before    { @course_ware1.update_read_count_of(@user,3) }
        
        it {
          @course_ware1.has_read?(@user).should == true
        }

        it {
          @course_ware1.set_unread_by!(@user)
          @course_ware1.has_read?(@user).should == false
        }

        it {
          expect {
            @course_ware1.set_unread_by!(@user)
          }.to change {
            @course_ware1.readed_users_count
          }.by(-1)
        }
      end

      context '验证 read_count > total_count' do
        it{expect {@course_ware1.update_read_count_of(@user,4)}.to change {@course_ware1.readed_users_count}.by(0)}
      end

      context '验证  read_count == fotal_count && !read' do
        before    do 
          @reading = CourseWareReading.new(:course_ware => @course_ware1, :user => @user, :read => false, :read_count => 3) 
        end
        it{ @reading.valid? .should == false }
      end
    end

    describe '#sign_reading #sign_no_reading' do
      context '验证 read_count' do
        before    { @course_ware.set_read_by!(@user) }
        it  { 
          @course_ware.course_ware_readings.by_user(@user).first.read_count == nil
        }
      end

      context '标记为已读' do
        it{expect {@course_ware.set_read_by!(@user)}.to change {@course_ware.readed_users_count}.by(1)}
      end

      context '标记为未读' do
        before    { @course_ware.set_read_by!(@user) }
        it{expect { @course_ware.set_unread_by!(@user)}.to change {@course_ware.readed_users_count}.by(-1)}
      end
    end

    describe '#has_read?' do
      context '用户未读' do
        it    { @course_ware.has_read?(@user).should == false}
      end
      context '用户已经读' do
        before{ @course_ware.set_read_by!(@user) }
        it    { @course_ware.has_read?(@user).should == true}
      end
    end

    describe '#readed_users_count' do
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }
      let(:user3) { FactoryGirl.create(:user) }
      let(:user4) { FactoryGirl.create(:user) }
      let(:user5) { FactoryGirl.create(:user) }
      before do 
        @course_ware.set_read_by!(user1)
        @course_ware.set_read_by!(user2)
        @course_ware.set_read_by!(user3)
        @course_ware.set_read_by!(user4)
        @course_ware.set_read_by!(user5)
      end
      it    { @course_ware.readed_users_count.should == 5 }
    end
  end

  describe '网络视频类型' do
    before {
      @course_ware = FactoryGirl.create :course_ware, :kind => :youku
    }

    it {
      CourseWare.last.is_web_video?.should == true
    }

    it {
      CourseWare.last.total_count.should == 1000
    }
  end

  describe 'by_course' do
    before{
      @course_1 = FactoryGirl.create(:course)
      @chapter_1_1 = FactoryGirl.create(:chapter, :course => @course_1)
      @course_ware_1_1_1 = FactoryGirl.create(:course_ware, :chapter => @chapter_1_1)
      @course_ware_1_1_2 = FactoryGirl.create(:course_ware, :chapter => @chapter_1_1)
      @chapter_1_2 = FactoryGirl.create(:chapter, :course => @course_1)
      @course_ware_1_2_1 = FactoryGirl.create(:course_ware, :chapter => @chapter_1_2)

      @course_2 = FactoryGirl.create(:course)
      @chapter_2_1 = FactoryGirl.create(:chapter, :course => @course_2)
      @course_ware_2_1 = FactoryGirl.create(:course_ware, :chapter => @chapter_2_1)
    }

    it{
      CourseWare.by_course(@course_1).should =~ [
        @course_ware_1_1_1,
        @course_ware_1_1_2,
        @course_ware_1_2_1
      ]
    }

    it{
      CourseWare.by_course(@course_2).should =~ [@course_ware_2_1]
    }
  end

  describe 'CourseWare.read_with_user(user)' do
    before{
      @course_ware_1 = FactoryGirl.create(:course_ware)
      @course_ware_2 = FactoryGirl.create(:course_ware)
      @course_ware_3 = FactoryGirl.create(:course_ware)
      @course_ware_4 = FactoryGirl.create(:course_ware)

      @user_1 = FactoryGirl.create(:user)
      @user_2 = FactoryGirl.create(:user)
    }

    it{
      CourseWare.read_with_user(@user_1).should == []
    }

    it{
      CourseWare.read_with_user(@user_2).should == []
    }

    describe '分别进行阅读' do
      before{
        @course_ware_1.set_read_by!(@user_1)
        @course_ware_4.set_read_by!(@user_1)

        @course_ware_1.set_read_by!(@user_2)
        @course_ware_3.set_read_by!(@user_2)
      }

      it{
        CourseWare.read_with_user(@user_1).should =~ [
          @course_ware_1,
          @course_ware_4
        ]
      }

      it{
        CourseWare.read_with_user(@user_2).should =~ [
          @course_ware_1,
          @course_ware_3
        ]
      }
    end


  end


  context '#update_read_count_of(user)' do
    before {
      @course_ware = FactoryGirl.create :course_ware
      @user = FactoryGirl.create :user
    }

    it {
      @course_ware.update_read_count_of(@user, 5)
    }
  end

end
