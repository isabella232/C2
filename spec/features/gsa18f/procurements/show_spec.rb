feature "View Gsa18F procurement" do
  scenario "requester can see procurement details" do
    requester = create(:user, client_slug: "gsa18f")
    procurement = create(:gsa18f_procurement, :with_steps, requester: requester, urgency: 10)
    proposal = procurement.proposal

    login_as(requester)

    visit proposal_path(proposal)

    expect(page).to have_content(procurement.purchase_type)
  end


  scenario "after last step is completed shows the pegasys document number", js: true do
    procurement = create(:gsa18f_procurement, :with_beta_steps)
    proposal = procurement.proposal

    login_as(proposal.requester)
    visit proposal_path(proposal)
    expect(page).not_to have_content("Pegasys Document Number")


    procurement.individual_steps.each do |step|
      login_as(User.find(step.user_id))
      visit proposal_path(proposal)
      wait_for_ajax
      click_on("Approve")
    end


    visit proposal_path(proposal)
    expect(page).to have_content("Pegasys Document Number")
  end

  scenario "requester cant see tock_project unless is_tock_billable is true", js: true do
    proposal = create_and_visit_proposal_beta
    visit proposal_path(proposal)
    expect(page).not_to have_content("Tock project number")
    js_activate_modify_proposal
    js_modify_checkbox
    expect(page).to have_content("Tock project number")
    visit proposal_path(proposal)
  end

  scenario "requester cant see client_billed unless is_tock_billable is true", js: true do
    proposal = create_and_visit_proposal_beta
    visit proposal_path(proposal)
    expect(page).not_to have_content("Client has been billed")
    js_activate_modify_proposal
    js_modify_checkbox
    expect(page).to have_content("Client has been billed")
    visit proposal_path(proposal)
  end

  def js_activate_modify_proposal(modify = "ul.request-actions .edit-button button")
    find(modify).trigger("click")
  end


  def js_modify_checkbox(text = "foo", selector = '#gsa18f_procurement_is_tock_billable', submit = ".request-actions .save-button button")
    find(:css, selector).set(true)
    find(submit).trigger("click")
    find('.save_confirm-modal-content .form-button[data-modal-event="confirm"]').trigger("click")
    wait_for_ajax
  end


  def create_and_visit_proposal_beta
    procurement = create(:gsa18f_procurement, :with_beta_requester)
    proposal = procurement.proposal
    login_as(proposal.requester)
    visit proposal_path(proposal)
    return proposal
  end

end
