import { Link } from 'react-router-dom';

const DividingCircle: React.FC = () => <span aria-hidden>{' · '}</span>;

export const LinkFooter: React.FC<{
  multiColumn: boolean;
}> = ({ multiColumn: _multiColumn }) => {
  return (
    <div className='link-footer'>
      <p>
        <strong>x4ai</strong>:{' '}
        <Link to='/about'>About</Link>
        <DividingCircle />
        <Link to='/terms-of-service'>Terms</Link>
        <DividingCircle />
        <Link to='/privacy-policy'>Privacy</Link>
        <DividingCircle />
        <a href='/.well-known/ai-agent.json' target='_blank' rel='noopener'>
          AI Policy
        </a>
      </p>
    </div>
  );
};
