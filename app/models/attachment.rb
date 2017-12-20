class Attachment < ActiveRecord::Base
  has_paper_trail class_name: "C2Version"

  has_attached_file :file
  validates_attachment_content_type :file, content_type: [
    /\Aapplication\/vnd\..*/,
    "application/msword",
    "application/octet-stream",
    "application/pdf",
    /image\/p?jpeg/,
    /image\/(x-)?png/,
    "image/tiff",
    "text/rtf",
  ]

  belongs_to :proposal
  belongs_to :user

  validates :file, presence: true
  validates :proposal, presence: true
  validates :user, presence: true

  scope :with_users, -> { includes :user }

  # Default url for attachments expires after 10 minutes
  def url
    file.expiring_url(10 * 60)
  end
end
