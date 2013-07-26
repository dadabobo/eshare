require "spec_helper"

describe Question do

  before {
    @question_user         = FactoryGirl.create :user
    @question     = FactoryGirl.create :question, :creator => @question_user
    @vote_user = FactoryGirl.create :user
  }

  describe "回答数 = 2" do
    before {
      2.times {
        FactoryGirl.create(:answer, :question => @question)
      }

      @question.destroy_by_creator
    }

    it "not deleted" do
      @question.deleted?.should == false
    end
  end

  describe "回答数 > 2" do
    before {
      3.times {
        FactoryGirl.create(:answer, :question => @question)
      }

      @question.destroy_by_creator
    }

    it "not deleted" do
      @question.deleted?.should == false
    end
  end

  describe "有一个回答 && 投正票" do
    before {
      @answer = FactoryGirl.create(:answer, :question => @question)
      @answer.vote_up_by! @vote_user

      @question.destroy_by_creator
    }

    it "not deleted" do
      @question.deleted?.should == false
    end
  end

  describe "有一个回答" do
    before {
      @answer = FactoryGirl.create(:answer, :question => @question)

      @question.destroy_by_creator
    }

    it "deleted" do
      @question.deleted?.should == true
    end
  end

  describe "有一个回答 && 投反票" do
    before {
      @answer = FactoryGirl.create(:answer, :question => @question)
      @answer.vote_down_by! @vote_user

      @question.destroy_by_creator
    }

    it "deleted" do
      @question.deleted?.should == true
    end
  end

  describe "有一个回答 && 投反票 + 投正票" do
    before {
      @answer = FactoryGirl.create(:answer, :question => @question)
      @answer.vote_down_by! @vote_user
      @answer.vote_up_by! @vote_user

      @question.destroy_by_creator
    }

    it "deleted" do
      @question.deleted?.should == false
    end
  end


  describe "有一个回答 && 投正票 + 投反票" do
    before {
      @answer = FactoryGirl.create(:answer, :question => @question)
      @answer.vote_up_by! @vote_user
      @answer.vote_down_by! @vote_user

      @question.destroy_by_creator
    }

    it "deleted" do
      @question.deleted?.should == true
    end
  end

  describe "有0个回答" do
    before {
      @question.destroy_by_creator
    }

    it "deleted" do
      @question.deleted?.should == true
    end

    it "not real deleted" do
      @question.reload
      @question.valid?.should == true
    end
  end

end