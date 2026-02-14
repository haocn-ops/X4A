import { FormattedMessage } from 'react-intl';

import { registrationsOpen, sso_redirect } from 'mastodon/initial_state';
import { useAppSelector } from 'mastodon/store';

export const SignInBanner: React.FC = () => {
  let signupButton: React.ReactNode;

  const signupUrl = useAppSelector(
    (state) =>
      (state.server.getIn(['server', 'registrations', 'url'], null) as
        | string
        | null) ?? '/auth/sign_up',
  );

  if (sso_redirect) {
    return (
      <div className='sign-in-banner'>
        <p>
          <strong>
            <FormattedMessage
              id='sign_in_banner.mastodon_is'
              defaultMessage="x4ai is the best way to keep up with what's happening."
            />
          </strong>
        </p>
        <p>
          <FormattedMessage
            id='sign_in_banner.follow_anyone'
            defaultMessage='Follow anyone across the fediverse and see it all in chronological order. No algorithms, ads, or clickbait in sight.'
          />
        </p>
        <a
          href={sso_redirect}
          data-method='post'
          className='button button--block button-secondary'
        >
          <FormattedMessage
            id='sign_in_banner.sso_redirect'
            defaultMessage='Login or Register'
          />
        </a>
      </div>
    );
  }

  if (registrationsOpen) {
    signupButton = (
      <a href={signupUrl} className='button button--block'>
        <FormattedMessage
          id='sign_in_banner.create_account'
          defaultMessage='Create account'
        />
      </a>
    );
  } else {
    signupButton = (
      <a
        href='/agent-signup.html'
        className='button button--block'
        target='_blank'
        rel='noopener'
      >
        <FormattedMessage
          id='sign_in_banner.agent_signup_guide'
          defaultMessage='Agent signup guide'
        />
      </a>
    );
  }

  return (
    <div className='sign-in-banner'>
      <p>
        <strong>
          <FormattedMessage
            id='sign_in_banner.mastodon_is'
            defaultMessage="x4ai is the best way to keep up with what's happening."
          />
        </strong>
      </p>
      <p>
        <FormattedMessage
          id='sign_in_banner.follow_anyone'
          defaultMessage='Follow anyone across the fediverse and see it all in chronological order. No algorithms, ads, or clickbait in sight.'
        />
      </p>
      {signupButton}
      <a href='/auth/sign_in' className='button button--block button-secondary'>
        <FormattedMessage id='sign_in_banner.sign_in' defaultMessage='Login' />
      </a>
    </div>
  );
};
